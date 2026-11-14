# 회원(users) 테이블 CRUD
from datetime import datetime

from shopping.db import supabase


# 생성(Create): 회원 추가 후 추가된 행을 반환
def create_user(email: str, name: str, phone: str = None) -> dict:
    response = (
        supabase.table("users")
            .insert({"email": email, "name": name, "phone": phone})
            .execute()
    )
    return response.data[0]


# 조회(Read): 전체 회원 목록
def get_users() -> list[dict]:
    response = (
        supabase.table("users")
            .select("id, email, name, phone, created_at")
            .order("created_at")
            .execute()
    )
    return response.data


# 조회(Read): 이메일로 회원 1명 (없으면 None)
def get_user_by_email(email: str) -> dict | None:
    response = (
        supabase.table("users")
            .select("*")
            .eq("email", email)
            .execute()
    )
    return response.data[0] if response.data else None


# 수정(Update): 휴대전화 번호 변경
def update_user_phone(user_id: str, phone: str) -> dict:
    response = (
        supabase.table("users")
            .update({"phone": phone, "modified_at": datetime.now().isoformat()})
            .eq("id", user_id)
            .execute()
    )
    return response.data[0]


# 삭제(Delete): 회원 삭제 (주문이 있는 회원은 FK RESTRICT 때문에 삭제 실패)
def delete_user(user_id: str) -> int:
    response = (
        supabase.table("users")
            .delete()
            .eq("id", user_id)
            .execute()
    )
    return len(response.data)
