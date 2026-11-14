-- =====================================================================
-- [심화] 트랜잭션 기반 주문 함수 (Supabase RPC)
-- 참고: [특강] PostgreSQL 함수와 프로시저 - 2. 원자적 주문 함수
--
-- 주문 1건 = (1) 상품 재고 차감 + (2) 주문 행 추가
-- 두 작업을 하나의 함수로 묶어서, 중간에 실패하면 둘 다 ROLLBACK 된다.
-- =====================================================================
CREATE OR REPLACE FUNCTION place_order(
    p_user_id    uuid,
    p_product_id uuid,
    p_quantity   int
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    v_product RECORD;
    v_order_id uuid;
BEGIN
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION '주문 수량은 1개 이상이어야 합니다.';
    END IF;

    SELECT id, name, price, stock INTO v_product
    FROM products WHERE id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION '존재하지 않는 상품입니다. (ID: %)', p_product_id;
    END IF;

    IF v_product.stock < p_quantity THEN
        RAISE EXCEPTION '재고가 부족합니다. (재고: %, 주문: %)', v_product.stock, p_quantity;
    END IF;

    -- (1) 재고 차감
    UPDATE products
    SET stock = stock - p_quantity, modified_at = now()
    WHERE id = p_product_id;

    -- (2) 주문 추가 : user_id 가 없는 회원이면 FK 위반 → (1)까지 함께 ROLLBACK
    INSERT INTO orders (user_id, product_id, item_name, price, quantity, total_price)
    VALUES (p_user_id, v_product.id, v_product.name, v_product.price, p_quantity,
            v_product.price * p_quantity)
    RETURNING id INTO v_order_id;

    RETURN jsonb_build_object(
        'success', true,
        'order_id', v_order_id,
        'total_price', v_product.price * p_quantity
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION '주문 처리 실패 (트랜잭션 롤백): %', SQLERRM;
END;
$$;

-- SQL로 직접 확인하는 COMMIT / ROLLBACK 예시 (2장 5강~6강)
-- BEGIN;
--   UPDATE products SET stock = stock - 1 WHERE name = '무선 기계식 키보드';
--   SELECT name, stock FROM products;   -- 9 로 보임
-- ROLLBACK;
--   SELECT name, stock FROM products;   -- 다시 10 (취소됨)
