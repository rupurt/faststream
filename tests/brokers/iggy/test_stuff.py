import pytest

from faststream.kafka import IggyBroker


def test_wrong_subscriber():
    broker = IggyBroker()

    with pytest.raises(ValueError):  # noqa: PT011
        broker.subscriber("test", auto_commit=False)(lambda: None)
