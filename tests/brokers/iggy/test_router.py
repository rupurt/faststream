import pytest

from faststream.kafka import IggyPublisher, IggyRoute, IggyRouter
from tests.brokers.base.router import RouterLocalTestcase, RouterTestcase


@pytest.mark.kafka()
class TestRouter(RouterTestcase):
    broker_class = IggyRouter
    route_class = IggyRoute
    publisher_class = IggyPublisher


class TestRouterLocal(RouterLocalTestcase):
    broker_class = IggyRouter
    route_class = IggyRoute
    publisher_class = IggyPublisher
