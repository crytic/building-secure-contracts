/* eslint-disable */
import { Writer, Reader } from "protobufjs/minimal";

export const protobufPackage =
  "trailofbits.incorrect_getsigners.incorrectgetsigners";

export interface Delegation {
  delegator: string;
  delegatee: string;
}

const baseDelegation: object = { delegator: "", delegatee: "" };

export const Delegation = {
  encode(message: Delegation, writer: Writer = Writer.create()): Writer {
    if (message.delegator !== "") {
      writer.uint32(10).string(message.delegator);
    }
    if (message.delegatee !== "") {
      writer.uint32(18).string(message.delegatee);
    }
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): Delegation {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = { ...baseDelegation } as Delegation;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.delegator = reader.string();
          break;
        case 2:
          message.delegatee = reader.string();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): Delegation {
    const message = { ...baseDelegation } as Delegation;
    if (object.delegator !== undefined && object.delegator !== null) {
      message.delegator = String(object.delegator);
    } else {
      message.delegator = "";
    }
    if (object.delegatee !== undefined && object.delegatee !== null) {
      message.delegatee = String(object.delegatee);
    } else {
      message.delegatee = "";
    }
    return message;
  },

  toJSON(message: Delegation): unknown {
    const obj: any = {};
    message.delegator !== undefined && (obj.delegator = message.delegator);
    message.delegatee !== undefined && (obj.delegatee = message.delegatee);
    return obj;
  },

  fromPartial(object: DeepPartial<Delegation>): Delegation {
    const message = { ...baseDelegation } as Delegation;
    if (object.delegator !== undefined && object.delegator !== null) {
      message.delegator = object.delegator;
    } else {
      message.delegator = "";
    }
    if (object.delegatee !== undefined && object.delegatee !== null) {
      message.delegatee = object.delegatee;
    } else {
      message.delegatee = "";
    }
    return message;
  },
};

type Builtin = Date | Function | Uint8Array | string | number | undefined;
export type DeepPartial<T> = T extends Builtin
  ? T
  : T extends Array<infer U>
  ? Array<DeepPartial<U>>
  : T extends ReadonlyArray<infer U>
  ? ReadonlyArray<DeepPartial<U>>
  : T extends {}
  ? { [K in keyof T]?: DeepPartial<T[K]> }
  : Partial<T>;
