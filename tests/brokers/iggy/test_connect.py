import pytest

from faststream.iggy import IggyBroker
from tests.brokers.base.connection import BrokerConnectionTestcase


@pytest.mark.iggy()
class TestConnection(BrokerConnectionTestcase):
    broker = IggyBroker

    def get_broker_args(self, settings):
        return {"bootstrap_servers": settings.url}
