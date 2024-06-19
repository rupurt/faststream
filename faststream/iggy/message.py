from typing import TYPE_CHECKING, Any, Protocol, Tuple, Union

from faststream.broker.message import StreamMessage

if TYPE_CHECKING:
    from aiokafka import ConsumerRecord


class ConsumerProtocol(Protocol):
    """A protocol for Iggy consumers."""

    async def commit(self) -> None: ...


class FakeConsumer:
    """A fake Iggy consumer."""

    async def commit(self) -> None:
        pass


FAKE_CONSUMER = FakeConsumer()


class IggyMessage(
    StreamMessage[
        Union[
            "ConsumerRecord",
            Tuple["ConsumerRecord", ...],
        ]
    ]
):
    """Represents a Iggy message in the FastStream framework.

    This class extends `StreamMessage` and is specialized for handling Iggy ConsumerRecord objects.
    """

    def __init__(
        self,
        *args: Any,
        consumer: ConsumerProtocol,
        **kwargs: Any,
    ) -> None:
        super().__init__(*args, **kwargs)

        self.consumer = consumer


class IggyAckableMessage(IggyMessage):
    async def ack(self) -> None:
        """Acknowledge the Iggy message."""
        if not self.committed:
            await self.consumer.commit()
            await super().ack()
