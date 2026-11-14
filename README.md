# KANT Supabase Shop

KANT 데이터베이스 & AI 활용 과제입니다. 쇼핑몰의 회원·주문·상품 3개 테이블을 PostgreSQL(Supabase)에 설계하고, Python Supabase SDK로 CRUD를 구현합니다.

## 1. 기술 스택

| 기술 | 용도 |
| --- | --- |
| Python 3.13 / uv | 프로젝트 생성, 가상환경과 의존성 관리 |
| Supabase (PostgreSQL) | 데이터베이스, 인증, RLS |
| supabase-py | Python 클라이언트 SDK |
| python-dotenv | `.env`에서 접속 정보 로드 |

## 2. 폴더 구조

```text
KANT_Supabase_Shop/
├── main.py              # 실행 진입점
├── shopping/
│   ├── db.py            # Supabase 클라이언트 생성
│   ├── users.py         # 회원 CRUD
│   ├── products.py      # 상품 CRUD
│   └── orders.py        # 주문 CRUD
├── sql/
│   ├── 01_schema.sql    # 테이블 생성 (PK, FK, 제약조건)
│   ├── 02_transaction.sql  # [심화] 트랜잭션 검증
│   └── 03_rls.sql       # [심화] RLS 정책
├── notebooks/           # CRUD 실행 결과 확인용 노트북
├── docs/images/         # README 캡처 이미지
├── .env.example         # 환경 변수 예시
├── pyproject.toml
└── uv.lock
```

## 3. 실행 방법

```bash
uv sync
cp .env.example .env   # SUPABASE_URL, SUPABASE_ANON_KEY 입력
uv run main.py
```

## 4. 테이블 설계

> TODO: 회원 / 상품 / 주문 테이블 상세 (컬럼, 타입, PK, FK, 제약조건) 표와 Supabase 캡처

## 5. CRUD 동작 화면

> TODO: 테이블별 생성·조회·수정·삭제 실행 결과 캡처

## 6. [심화] 트랜잭션 / RLS

> TODO
