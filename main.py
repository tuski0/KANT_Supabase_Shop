from shopping.db import supabase


def main():
    # Supabase 연결 확인용 진입점
    print("Supabase client:", supabase is not None)


if __name__ == "__main__":
    main()
