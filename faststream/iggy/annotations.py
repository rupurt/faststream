from aiokafka import AIOIggyConsumer
from typing_extensions import Annotated

from faststream.annotations import ContextRepo, Logger, NoCast
from faststream.kafka.broker import IggyBroker as KB
from faststream.kafka.message import IggyMessage as KM
from faststream.kafka.publisher.producer import AioIggyFastProducer
from faststream.utils.context import Context

__all__ = (
    "Logger",
    "ContextRepo",
    "NoCast",
    "IggyMessage",
    "IggyBroker",
    "IggyProducer",
)

Consumer = Annotated[AIOIggyConsumer, Context("handler_.consumer")]
IggyMessage = Annotated[KM, Context("message")]
IggyBroker = Annotated[KB, Context("broker")]
IggyProducer = Annotated[AioIggyFastProducer, Context("broker._producer")]
