/* eslint-disable */
import {
  Order,
  Counterparty,
  orderFromJSON,
  orderToJSON,
} from "../../../../ibc/core/channel/v1/channel";
import { Reader, Writer } from "protobufjs/minimal";

export const protobufPackage = "ibc.core.port.v1";

/** QueryAppVersionRequest is the request type for the Query/AppVersion RPC method */
export interface QueryAppVersionRequest {
  /** port unique identifier */
  port_id: string;
  /** connection unique identifier */
  connection_id: string;
  /** whether the channel is ordered or unordered */
  ordering: Order;
  /** counterparty channel end */
  counterparty: Counterparty | undefined;
  /** proposed version */
  proposed_version: string;
}

/** QueryAppVersionResponse is the response type for the Query/AppVersion RPC method. */
export interface QueryAppVersionResponse {
  /** port id associated with the request identifiers */
  port_id: string;
  /** supported app version */
  version: string;
}

const baseQueryAppVersionRequest: object = {
  port_id: "",
  connection_id: "",
  ordering: 0,
  proposed_version: "",
};

export const QueryAppVersionRequest = {
  encode(
    message: QueryAppVersionRequest,
    writer: Writer = Writer.create()
  ): Writer {
    if (message.port_id !== "") {
      writer.uint32(10).string(message.port_id);
    }
    if (message.connection_id !== "") {
      writer.uint32(18).string(message.connection_id);
    }
    if (message.ordering !== 0) {
      writer.uint32(24).int32(message.ordering);
    }
    if (message.counterparty !== undefined) {
      Counterparty.encode(
        message.counterparty,
        writer.uint32(34).fork()
      ).ldelim();
    }
    if (message.proposed_version !== "") {
      writer.uint32(42).string(message.proposed_version);
    }
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryAppVersionRequest {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = { ...baseQueryAppVersionRequest } as QueryAppVersionRequest;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.port_id = reader.string();
          break;
        case 2:
          message.connection_id = reader.string();
          break;
        case 3:
          message.ordering = reader.int32() as any;
          break;
        case 4:
          message.counterparty = Counterparty.decode(reader, reader.uint32());
          break;
        case 5:
          message.proposed_version = reader.string();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): QueryAppVersionRequest {
    const message = { ...baseQueryAppVersionRequest } as QueryAppVersionRequest;
    if (object.port_id !== undefined && object.port_id !== null) {
      message.port_id = String(object.port_id);
    } else {
      message.port_id = "";
    }
    if (object.connection_id !== undefined && object.connection_id !== null) {
      message.connection_id = String(object.connection_id);
    } else {
      message.connection_id = "";
    }
    if (object.ordering !== undefined && object.ordering !== null) {
      message.ordering = orderFromJSON(object.ordering);
    } else {
      message.ordering = 0;
    }
    if (object.counterparty !== undefined && object.counterparty !== null) {
      message.counterparty = Counterparty.fromJSON(object.counterparty);
    } else {
      message.counterparty = undefined;
    }
    if (
      object.proposed_version !== undefined &&
      object.proposed_version !== null
    ) {
      message.proposed_version = String(object.proposed_version);
    } else {
      message.proposed_version = "";
    }
    return message;
  },

  toJSON(message: QueryAppVersionRequest): unknown {
    const obj: any = {};
    message.port_id !== undefined && (obj.port_id = message.port_id);
    message.connection_id !== undefined &&
      (obj.connection_id = message.connection_id);
    message.ordering !== undefined &&
      (obj.ordering = orderToJSON(message.ordering));
    message.counterparty !== undefined &&
      (obj.counterparty = message.counterparty
        ? Counterparty.toJSON(message.counterparty)
        : undefined);
    message.proposed_version !== undefined &&
      (obj.proposed_version = message.proposed_version);
    return obj;
  },

  fromPartial(
    object: DeepPartial<QueryAppVersionRequest>
  ): QueryAppVersionRequest {
    const message = { ...baseQueryAppVersionRequest } as QueryAppVersionRequest;
    if (object.port_id !== undefined && object.port_id !== null) {
      message.port_id = object.port_id;
    } else {
      message.port_id = "";
    }
    if (object.connection_id !== undefined && object.connection_id !== null) {
      message.connection_id = object.connection_id;
    } else {
      message.connection_id = "";
    }
    if (object.ordering !== undefined && object.ordering !== null) {
      message.ordering = object.ordering;
    } else {
      message.ordering = 0;
    }
    if (object.counterparty !== undefined && object.counterparty !== null) {
      message.counterparty = Counterparty.fromPartial(object.counterparty);
    } else {
      message.counterparty = undefined;
    }
    if (
      object.proposed_version !== undefined &&
      object.proposed_version !== null
    ) {
      message.proposed_version = object.proposed_version;
    } else {
      message.proposed_version = "";
    }
    return message;
  },
};

const baseQueryAppVersionResponse: object = { port_id: "", version: "" };

export const QueryAppVersionResponse = {
  encode(
    message: QueryAppVersionResponse,
    writer: Writer = Writer.create()
  ): Writer {
    if (message.port_id !== "") {
      writer.uint32(10).string(message.port_id);
    }
    if (message.version !== "") {
      writer.uint32(18).string(message.version);
    }
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryAppVersionResponse {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = {
      ...baseQueryAppVersionResponse,
    } as QueryAppVersionResponse;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.port_id = reader.string();
          break;
        case 2:
          message.version = reader.string();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): QueryAppVersionResponse {
    const message = {
      ...baseQueryAppVersionResponse,
    } as QueryAppVersionResponse;
    if (object.port_id !== undefined && object.port_id !== null) {
      message.port_id = String(object.port_id);
    } else {
      message.port_id = "";
    }
    if (object.version !== undefined && object.version !== null) {
      message.version = String(object.version);
    } else {
      message.version = "";
    }
    return message;
  },

  toJSON(message: QueryAppVersionResponse): unknown {
    const obj: any = {};
    message.port_id !== undefined && (obj.port_id = message.port_id);
    message.version !== undefined && (obj.version = message.version);
    return obj;
  },

  fromPartial(
    object: DeepPartial<QueryAppVersionResponse>
  ): QueryAppVersionResponse {
    const message = {
      ...baseQueryAppVersionResponse,
    } as QueryAppVersionResponse;
    if (object.port_id !== undefined && object.port_id !== null) {
      message.port_id = object.port_id;
    } else {
      message.port_id = "";
    }
    if (object.version !== undefined && object.version !== null) {
      message.version = object.version;
    } else {
      message.version = "";
    }
    return message;
  },
};

/** Query defines the gRPC querier service */
export interface Query {
  /** AppVersion queries an IBC Port and determines the appropriate application version to be used */
  AppVersion(request: QueryAppVersionRequest): Promise<QueryAppVersionResponse>;
}

export class QueryClientImpl implements Query {
  private readonly rpc: Rpc;
  constructor(rpc: Rpc) {
    this.rpc = rpc;
  }
  AppVersion(
    request: QueryAppVersionRequest
  ): Promise<QueryAppVersionResponse> {
    const data = QueryAppVersionRequest.encode(request).finish();
    const promise = this.rpc.request(
      "ibc.core.port.v1.Query",
      "AppVersion",
      data
    );
    return promise.then((data) =>
      QueryAppVersionResponse.decode(new Reader(data))
    );
  }
}

interface Rpc {
  request(
    service: string,
    method: string,
    data: Uint8Array
  ): Promise<Uint8Array>;
}

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
