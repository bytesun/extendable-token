export const idlFactory = ({ IDL }) => {
  const TokenIndex = IDL.Nat32;
  const Metadata = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Balance__1 = IDL.Nat;
  const AccountIdentifier__1 = IDL.Text;
  const TokenIdentifier = IDL.Text;
  const AccountIdentifier = IDL.Text;
  const User = IDL.Variant({
    'principal' : IDL.Principal,
    'address' : AccountIdentifier,
  });
  const BalanceRequest = IDL.Record({
    'token' : TokenIdentifier,
    'user' : User,
  });
  const Balance = IDL.Nat;
  const CommonError__1 = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const BalanceResponse = IDL.Variant({
    'ok' : Balance,
    'err' : CommonError__1,
  });
  const Extension = IDL.Text;
  const TokenIdentifier__1 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const Result_4 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : CommonError });
  const RegisterTokenRequest = IDL.Record({
    'owner' : AccountIdentifier__1,
    'metadata' : Metadata,
    'supply' : Balance__1,
  });
  const Result_2 = IDL.Variant({ 'ok' : TokenIndex, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(AccountIdentifier__1, Balance__1)),
    'err' : CommonError,
  });
  const Result = IDL.Variant({ 'ok' : Balance__1, 'err' : CommonError });
  const Memo = IDL.Vec(IDL.Nat8);
  const SubAccount = IDL.Vec(IDL.Nat8);
  const TransferRequest = IDL.Record({
    'to' : User,
    'token' : TokenIdentifier,
    'notify' : IDL.Bool,
    'from' : User,
    'memo' : Memo,
    'subaccount' : IDL.Opt(SubAccount),
    'amount' : Balance,
  });
  const TransferResponse = IDL.Variant({
    'ok' : Balance,
    'err' : IDL.Variant({
      'CannotNotify' : AccountIdentifier,
      'InsufficientBalance' : IDL.Null,
      'InvalidToken' : TokenIdentifier,
      'Rejected' : IDL.Null,
      'Unauthorized' : AccountIdentifier,
      'Other' : IDL.Text,
    }),
  });
  const advanced_token = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'allMetadata' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, IDL.Tuple(Metadata, Balance__1)))],
        ['query'],
      ),
    'allRegistry' : IDL.Func(
        [],
        [
          IDL.Vec(
            IDL.Tuple(
              TokenIndex,
              IDL.Vec(IDL.Tuple(AccountIdentifier__1, Balance__1)),
            )
          ),
        ],
        ['query'],
      ),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'changeAdmin' : IDL.Func([IDL.Principal], [], []),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'metadata' : IDL.Func([TokenIdentifier__1], [Result_4], ['query']),
    'numberOfTokenHolders' : IDL.Func(
        [TokenIdentifier__1],
        [Result_3],
        ['query'],
      ),
    'numberOfTokens' : IDL.Func([], [IDL.Nat], ['query']),
    'registerToken' : IDL.Func([RegisterTokenRequest], [Result_2], []),
    'registry' : IDL.Func([TokenIdentifier__1], [Result_1], ['query']),
    'supply' : IDL.Func([TokenIdentifier__1], [Result], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
  });
  return advanced_token;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
