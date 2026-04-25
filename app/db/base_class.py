from typing import Any
from sqlalchemy.ext.declarative import as_declarative, declared_attr

@as_declarative()
class Base:
    id: Any
    __name__: str

    # 自动将类名转换为小写表名。例如：类名是 User，表名自动变为 user
    @declared_attr
    def __tablename__(cls) -> str:
        return cls.__name__.lower()