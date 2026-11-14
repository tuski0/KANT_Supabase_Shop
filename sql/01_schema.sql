-- =====================================================================
-- 쇼핑몰 테이블 생성 (Supabase SQL Editor에서 실행)
-- 네이밍 규칙 (데이터베이스 & AI 활용 1장 2강 실습 4)
--   - 테이블: 소문자, 복수형, 스네이크 케이스 (users, products, orders)
--   - 외래키 컬럼: {참조 테이블 단수형}_id (user_id, product_id)
--   - 제약조건: {테이블}_{컬럼}_{종류} (users_email_unique, orders_quantity_check)
-- =====================================================================

-- 다시 실행할 수 있도록 기존 객체 삭제 (자식 → 부모 순서)
DROP FUNCTION IF EXISTS place_order(uuid, uuid, int);
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- 1) 회원 (users)
CREATE TABLE users (
    id          uuid        DEFAULT gen_random_uuid(),
    email       text        NOT NULL,
    name        text        NOT NULL,
    phone       text,
    created_at  timestamptz NOT NULL DEFAULT now(),
    modified_at timestamptz,
    CONSTRAINT users_pkey         PRIMARY KEY (id),
    CONSTRAINT users_email_unique UNIQUE (email)
);

-- 2) 상품 (products)
CREATE TABLE products (
    id          uuid        DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    price       int         NOT NULL,
    stock       int         NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now(),
    modified_at timestamptz,
    CONSTRAINT products_pkey        PRIMARY KEY (id),
    CONSTRAINT products_price_check CHECK (price >= 0),
    CONSTRAINT products_stock_check CHECK (stock >= 0)
);

-- 3) 주문 (orders) : 회원 1명이 상품 1개를 수량만큼 주문
--    item_name, price 는 주문 시점 값을 복사해 보관 (스냅샷)
CREATE TABLE orders (
    id           uuid        DEFAULT gen_random_uuid(),
    user_id      uuid        NOT NULL,
    product_id   uuid        NOT NULL,
    item_name    text        NOT NULL,
    price        int         NOT NULL,
    quantity     int         NOT NULL DEFAULT 1,
    total_price  int         NOT NULL,
    order_status text        NOT NULL DEFAULT 'READY',
    created_at   timestamptz NOT NULL DEFAULT now(),
    modified_at  timestamptz,
    CONSTRAINT orders_pkey              PRIMARY KEY (id),
    CONSTRAINT orders_user_id_fkey      FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE RESTRICT,
    CONSTRAINT orders_product_id_fkey   FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    CONSTRAINT orders_quantity_check    CHECK (quantity > 0),
    CONSTRAINT orders_total_price_check CHECK (total_price >= 0),
    CONSTRAINT orders_order_status_check
        CHECK (order_status IN ('READY', 'PAID', 'SHIPPING', 'DONE', 'CANCEL'))
);

-- 샘플 데이터
INSERT INTO users (email, name, phone) VALUES
    ('hong@example.com', '홍길동', '010-1111-1111'),
    ('lee@example.com',  '이순신', '010-2222-2222');

INSERT INTO products (name, price, stock) VALUES
    ('무선 기계식 키보드',     120000, 10),
    ('인체공학 버티컬 마우스',  55000, 20);

-- 테이블 / PK / FK 확인용 조회
SELECT tc.table_name, tc.constraint_name, tc.constraint_type,
       kcu.column_name,
       ccu.table_name  AS ref_table,
       ccu.column_name AS ref_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
 AND tc.table_name = kcu.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON tc.constraint_name = ccu.constraint_name AND tc.constraint_type = 'FOREIGN KEY'
WHERE tc.table_schema = 'public'
  AND tc.table_name IN ('users', 'products', 'orders')
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE')
ORDER BY tc.table_name, tc.constraint_type;
