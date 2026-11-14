# 주문(orders) 테이블 CRUD
from datetime import datetime

from shopping.db import supabase
from shopping.products import get_product


# 생성(Create): 상품 정보를 조회해 주문 시점의 상품명·가격을 함께 저장
def create_order(user_id: str, product_id: str, quantity: int = 1) -> dict:
    product = get_product(product_id)
    if product is None:
        raise ValueError("존재하지 않는 상품입니다.")

    response = (
        supabase.table("orders")
            .insert({
                "user_id": user_id,
                "product_id": product_id,
                "item_name": product["name"],
                "price": product["price"],
                "quantity": quantity,
                "total_price": product["price"] * quantity,
            })
            .execute()
    )
    return response.data[0]


# 조회(Read): 주문 목록 + 주문한 회원 이름 (FK 관계를 이용한 조인 조회)
def get_orders(user_id: str = None) -> list[dict]:
    query = (
        supabase.table("orders")
            .select("id, item_name, price, quantity, total_price, order_status, users(name)")
    )
    if user_id:
        query = query.eq("user_id", user_id)

    response = query.order("created_at").execute()
    return response.data


# 수정(Update): 주문 상태 변경 (READY, PAID, SHIPPING, DONE, CANCEL)
def update_order_status(order_id: str, order_status: str) -> dict:
    response = (
        supabase.table("orders")
            .update({"order_status": order_status, "modified_at": datetime.now().isoformat()})
            .eq("id", order_id)
            .execute()
    )
    return response.data[0]


# 삭제(Delete)
def delete_order(order_id: str) -> int:
    response = (
        supabase.table("orders")
            .delete()
            .eq("id", order_id)
            .execute()
    )
    return len(response.data)


# [심화] 트랜잭션 함수 호출: 재고 차감 + 주문 추가를 한 번에 (실패 시 둘 다 롤백)
def place_order(user_id: str, product_id: str, quantity: int) -> dict:
    response = supabase.rpc("place_order", {
        "p_user_id": user_id,
        "p_product_id": product_id,
        "p_quantity": quantity,
    }).execute()
    return response.data
