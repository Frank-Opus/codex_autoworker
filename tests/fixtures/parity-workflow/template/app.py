def greeting(name: str | None = None) -> str:
    if name:
        return f"Hello, {name}!"
    return "Hello, world!"


if __name__ == "__main__":
    print(greeting())
