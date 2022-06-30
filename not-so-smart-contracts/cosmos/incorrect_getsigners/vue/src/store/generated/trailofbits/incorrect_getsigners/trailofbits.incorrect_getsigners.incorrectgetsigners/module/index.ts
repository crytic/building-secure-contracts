// THIS FILE IS GENERATED AUTOMATICALLY. DO NOT MODIFY.

import { StdFee } from "@cosmjs/launchpad";
import { SigningStargateClient } from "@cosmjs/stargate";
import { Registry, OfflineSigner, EncodeObject, DirectSecp256k1HdWallet } from "@cosmjs/proto-signing";
import { Api } from "./rest";
import { MsgCreatePost } from "./types/incorrectgetsigners/tx";
import { MsgDelegate } from "./types/incorrectgetsigners/tx";
import { MsgDelegatePost } from "./types/incorrectgetsigners/tx";


const types = [
  ["/trailofbits.incorrect_getsigners.incorrectgetsigners.MsgCreatePost", MsgCreatePost],
  ["/trailofbits.incorrect_getsigners.incorrectgetsigners.MsgDelegate", MsgDelegate],
  ["/trailofbits.incorrect_getsigners.incorrectgetsigners.MsgDelegatePost", MsgDelegatePost],
  
];
export const MissingWalletError = new Error("wallet is required");

export const registry = new Registry(<any>types);

const defaultFee = {
  amount: [],
  gas: "200000",
};

interface TxClientOptions {
  addr: string
}

interface SignAndBroadcastOptions {
  fee: StdFee,
  memo?: string
}

const txClient = async (wallet: OfflineSigner, { addr: addr }: TxClientOptions = { addr: "http://localhost:26657" }) => {
  if (!wallet) throw MissingWalletError;
  let client;
  if (addr) {
    client = await SigningStargateClient.connectWithSigner(addr, wallet, { registry });
  }else{
    client = await SigningStargateClient.offline( wallet, { registry });
  }
  const { address } = (await wallet.getAccounts())[0];

  return {
    signAndBroadcast: (msgs: EncodeObject[], { fee, memo }: SignAndBroadcastOptions = {fee: defaultFee, memo: ""}) => client.signAndBroadcast(address, msgs, fee,memo),
    msgCreatePost: (data: MsgCreatePost): EncodeObject => ({ typeUrl: "/trailofbits.incorrect_getsigners.incorrectgetsigners.MsgCreatePost", value: MsgCreatePost.fromPartial( data ) }),
    msgDelegate: (data: MsgDelegate): EncodeObject => ({ typeUrl: "/trailofbits.incorrect_getsigners.incorrectgetsigners.MsgDelegate", value: MsgDelegate.fromPartial( data ) }),
    msgDelegatePost: (data: MsgDelegatePost): EncodeObject => ({ typeUrl: "/trailofbits.incorrect_getsigners.incorrectgetsigners.MsgDelegatePost", value: MsgDelegatePost.fromPartial( data ) }),
    
  };
};

interface QueryClientOptions {
  addr: string
}

const queryClient = async ({ addr: addr }: QueryClientOptions = { addr: "http://localhost:1317" }) => {
  return new Api({ baseUrl: addr });
};

export {
  txClient,
  queryClient,
};
