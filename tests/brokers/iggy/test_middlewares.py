import pytest

from faststream.kafka import IggyBroker
from tests.brokers.base.middlewares import MiddlewareTestcase


@pytest.mark.kafka()
class TestMiddlewares(MiddlewareTestcase):
    broker_class = IggyBroker
