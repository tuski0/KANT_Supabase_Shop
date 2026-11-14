# 상품(products) 테이블 CRUD
from datetime import datetime

from shopping.db import supabase


# 생성(Create)
def create_product(name: str, price: int, stock: int = 0) -> dict:
    response = (
        supabase.table("products")
            .insert({"name": name, "price": price, "stock": stock})
            .execute()
    )
    return response.data[0]


# 조회(Read): 전체 상품 목록
def get_products() -> list[dict]:
    response = (
        supabase.table("products")
            .select("id, name, price, stock")
            .order("created_at")
            .execute()
    )
    return response.data


# 조회(Read): 상품 1개
def get_product(product_id: str) -> dict | None:
    response = (
        supabase.table("products")
            .select("*")
            .eq("id", product_id)
            .execute()
    )
    return response.data[0] if response.data else None


# 수정(Update): 가격과 재고 변경
def update_product(product_id: str, price: int, stock: int) -> dict:
    response = (
        supabase.table("products")
            .update({"price": price, "stock": stock, "modified_at": datetime.now().isoformat()})
            .eq("id", product_id)
            .execute()
    )
    return response.data[0]


# 삭제(Delete)
def delete_product(product_id: str) -> int:
    response = (
        supabase.table("products")
            .delete()
            .eq("id", product_id)
            .execute()
    )
    return len(response.data)
