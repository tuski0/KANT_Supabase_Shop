import os

from dotenv import load_dotenv
from supabase import Client, create_client

# 프로젝트 루트의 .env 파일에서 SUPABASE_URL, SUPABASE_ANON_KEY를 읽어옴
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_ANON_KEY")

if not url or not key:
    raise RuntimeError(".env에 SUPABASE_URL, SUPABASE_ANON_KEY를 설정하세요.")

supabase: Client = create_client(url, key)
