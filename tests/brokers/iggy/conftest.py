from dataclasses import dataclass

import pytest
import pytest_asyncio

from faststream.kafka import IggyBroker, IggyRouter, TestIggyBroker


@dataclass
class Settings:
    url = "localhost:9092"


@pytest.fixture(scope="session")
def settings():
    return Settings()


@pytest.fixture()
def router():
    return IggyRouter()


@pytest_asyncio.fixture()
async def broker(settings):
    broker = IggyBroker(settings.url, apply_types=False)
    async with broker:
        yield broker


@pytest_asyncio.fixture()
async def full_broker(settings):
    broker = IggyBroker(settings.url)
    async with broker:
        yield broker


@pytest_asyncio.fixture()
async def test_broker():
    broker = IggyBroker()
    async with TestIggyBroker(broker) as br:
        yield br
