/* eslint-disable */
import { Reader, Writer } from "protobufjs/minimal";
import { Params } from "../incorrectgetsigners/params";
import { Post } from "../incorrectgetsigners/post";
import { Delegation } from "../incorrectgetsigners/delegation";

export const protobufPackage =
  "trailofbits.incorrect_getsigners.incorrectgetsigners";

/** QueryParamsRequest is request type for the Query/Params RPC method. */
export interface QueryParamsRequest {}

/** QueryParamsResponse is response type for the Query/Params RPC method. */
export interface QueryParamsResponse {
  /** params holds all the parameters of this module. */
  params: Params | undefined;
}

export interface QueryPostsRequest {}

export interface QueryPostsResponse {
  Post: Post[];
}

export interface QueryDelegationsRequest {}

export interface QueryDelegationsResponse {
  delegation: Delegation[];
}

const baseQueryParamsRequest: object = {};

export const QueryParamsRequest = {
  encode(_: QueryParamsRequest, writer: Writer = Writer.create()): Writer {
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryParamsRequest {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = { ...baseQueryParamsRequest } as QueryParamsRequest;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(_: any): QueryParamsRequest {
    const message = { ...baseQueryParamsRequest } as QueryParamsRequest;
    return message;
  },

  toJSON(_: QueryParamsRequest): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial(_: DeepPartial<QueryParamsRequest>): QueryParamsRequest {
    const message = { ...baseQueryParamsRequest } as QueryParamsRequest;
    return message;
  },
};

const baseQueryParamsResponse: object = {};

export const QueryParamsResponse = {
  encode(
    message: QueryParamsResponse,
    writer: Writer = Writer.create()
  ): Writer {
    if (message.params !== undefined) {
      Params.encode(message.params, writer.uint32(10).fork()).ldelim();
    }
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryParamsResponse {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = { ...baseQueryParamsResponse } as QueryParamsResponse;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.params = Params.decode(reader, reader.uint32());
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): QueryParamsResponse {
    const message = { ...baseQueryParamsResponse } as QueryParamsResponse;
    if (object.params !== undefined && object.params !== null) {
      message.params = Params.fromJSON(object.params);
    } else {
      message.params = undefined;
    }
    return message;
  },

  toJSON(message: QueryParamsResponse): unknown {
    const obj: any = {};
    message.params !== undefined &&
      (obj.params = message.params ? Params.toJSON(message.params) : undefined);
    return obj;
  },

  fromPartial(object: DeepPartial<QueryParamsResponse>): QueryParamsResponse {
    const message = { ...baseQueryParamsResponse } as QueryParamsResponse;
    if (object.params !== undefined && object.params !== null) {
      message.params = Params.fromPartial(object.params);
    } else {
      message.params = undefined;
    }
    return message;
  },
};

const baseQueryPostsRequest: object = {};

export const QueryPostsRequest = {
  encode(_: QueryPostsRequest, writer: Writer = Writer.create()): Writer {
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryPostsRequest {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = { ...baseQueryPostsRequest } as QueryPostsRequest;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(_: any): QueryPostsRequest {
    const message = { ...baseQueryPostsRequest } as QueryPostsRequest;
    return message;
  },

  toJSON(_: QueryPostsRequest): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial(_: DeepPartial<QueryPostsRequest>): QueryPostsRequest {
    const message = { ...baseQueryPostsRequest } as QueryPostsRequest;
    return message;
  },
};

const baseQueryPostsResponse: object = {};

export const QueryPostsResponse = {
  encode(
    message: QueryPostsResponse,
    writer: Writer = Writer.create()
  ): Writer {
    for (const v of message.Post) {
      Post.encode(v!, writer.uint32(10).fork()).ldelim();
    }
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryPostsResponse {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = { ...baseQueryPostsResponse } as QueryPostsResponse;
    message.Post = [];
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.Post.push(Post.decode(reader, reader.uint32()));
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): QueryPostsResponse {
    const message = { ...baseQueryPostsResponse } as QueryPostsResponse;
    message.Post = [];
    if (object.Post !== undefined && object.Post !== null) {
      for (const e of object.Post) {
        message.Post.push(Post.fromJSON(e));
      }
    }
    return message;
  },

  toJSON(message: QueryPostsResponse): unknown {
    const obj: any = {};
    if (message.Post) {
      obj.Post = message.Post.map((e) => (e ? Post.toJSON(e) : undefined));
    } else {
      obj.Post = [];
    }
    return obj;
  },

  fromPartial(object: DeepPartial<QueryPostsResponse>): QueryPostsResponse {
    const message = { ...baseQueryPostsResponse } as QueryPostsResponse;
    message.Post = [];
    if (object.Post !== undefined && object.Post !== null) {
      for (const e of object.Post) {
        message.Post.push(Post.fromPartial(e));
      }
    }
    return message;
  },
};

const baseQueryDelegationsRequest: object = {};

export const QueryDelegationsRequest = {
  encode(_: QueryDelegationsRequest, writer: Writer = Writer.create()): Writer {
    return writer;
  },

  decode(input: Reader | Uint8Array, length?: number): QueryDelegationsRequest {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = {
      ...baseQueryDelegationsRequest,
    } as QueryDelegationsRequest;
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(_: any): QueryDelegationsRequest {
    const message = {
      ...baseQueryDelegationsRequest,
    } as QueryDelegationsRequest;
    return message;
  },

  toJSON(_: QueryDelegationsRequest): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial(
    _: DeepPartial<QueryDelegationsRequest>
  ): QueryDelegationsRequest {
    const message = {
      ...baseQueryDelegationsRequest,
    } as QueryDelegationsRequest;
    return message;
  },
};

const baseQueryDelegationsResponse: object = {};

export const QueryDelegationsResponse = {
  encode(
    message: QueryDelegationsResponse,
    writer: Writer = Writer.create()
  ): Writer {
    for (const v of message.delegation) {
      Delegation.encode(v!, writer.uint32(10).fork()).ldelim();
    }
    return writer;
  },

  decode(
    input: Reader | Uint8Array,
    length?: number
  ): QueryDelegationsResponse {
    const reader = input instanceof Uint8Array ? new Reader(input) : input;
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = {
      ...baseQueryDelegationsResponse,
    } as QueryDelegationsResponse;
    message.delegation = [];
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.delegation.push(Delegation.decode(reader, reader.uint32()));
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): QueryDelegationsResponse {
    const message = {
      ...baseQueryDelegationsResponse,
    } as QueryDelegationsResponse;
    message.delegation = [];
    if (object.delegation !== undefined && object.delegation !== null) {
      for (const e of object.delegation) {
        message.delegation.push(Delegation.fromJSON(e));
      }
    }
    return message;
  },

  toJSON(message: QueryDelegationsResponse): unknown {
    const obj: any = {};
    if (message.delegation) {
      obj.delegation = message.delegation.map((e) =>
        e ? Delegation.toJSON(e) : undefined
      );
    } else {
      obj.delegation = [];
    }
    return obj;
  },

  fromPartial(
    object: DeepPartial<QueryDelegationsResponse>
  ): QueryDelegationsResponse {
    const message = {
      ...baseQueryDelegationsResponse,
    } as QueryDelegationsResponse;
    message.delegation = [];
    if (object.delegation !== undefined && object.delegation !== null) {
      for (const e of object.delegation) {
        message.delegation.push(Delegation.fromPartial(e));
      }
    }
    return message;
  },
};

/** Query defines the gRPC querier service. */
export interface Query {
  /** Parameters queries the parameters of the module. */
  Params(request: QueryParamsRequest): Promise<QueryParamsResponse>;
  /** Queries a list of Posts items. */
  Posts(request: QueryPostsRequest): Promise<QueryPostsResponse>;
  /** Queries a list of Delegations items. */
  Delegations(
    request: QueryDelegationsRequest
  ): Promise<QueryDelegationsResponse>;
}

export class QueryClientImpl implements Query {
  private readonly rpc: Rpc;
  constructor(rpc: Rpc) {
    this.rpc = rpc;
  }
  Params(request: QueryParamsRequest): Promise<QueryParamsResponse> {
    const data = QueryParamsRequest.encode(request).finish();
    const promise = this.rpc.request(
      "trailofbits.incorrect_getsigners.incorrectgetsigners.Query",
      "Params",
      data
    );
    return promise.then((data) => QueryParamsResponse.decode(new Reader(data)));
  }

  Posts(request: QueryPostsRequest): Promise<QueryPostsResponse> {
    const data = QueryPostsRequest.encode(request).finish();
    const promise = this.rpc.request(
      "trailofbits.incorrect_getsigners.incorrectgetsigners.Query",
      "Posts",
      data
    );
    return promise.then((data) => QueryPostsResponse.decode(new Reader(data)));
  }

  Delegations(
    request: QueryDelegationsRequest
  ): Promise<QueryDelegationsResponse> {
    const data = QueryDelegationsRequest.encode(request).finish();
    const promise = this.rpc.request(
      "trailofbits.incorrect_getsigners.incorrectgetsigners.Query",
      "Delegations",
      data
    );
    return promise.then((data) =>
      QueryDelegationsResponse.decode(new Reader(data))
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
