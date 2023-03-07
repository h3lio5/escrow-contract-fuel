library error;

pub enum Error {
    EscrowNotInitialized: (),
    IncorrectEscrowState: (),
    IncorrectReceiver: (),
    IncorrectAssetReceived: (),
    InsufficientAmountReceived: (),
}