from app import greeting


def main() -> None:
    assert greeting() == "Hello, world!"
    assert greeting("Alice") == "Hello, Alice!"
    print("tests-ok")


if __name__ == "__main__":
    main()
