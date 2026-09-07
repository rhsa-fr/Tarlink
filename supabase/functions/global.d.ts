// Type declarations for Deno runtime and URL-based ESM imports in Supabase Edge Functions

declare namespace Deno {
  export interface Env {
    get(key: string): string | undefined;
    set(key: string, value: string): void;
    delete(key: string): void;
    toObject(): Record<string, string>;
  }

  export const env: Env;

  export function serve(
    handler: (request: Request) => Response | Promise<Response>,
    options?: { port?: number; hostname?: string; signal?: AbortSignal }
  ): void;
}

declare module "https://*" {
  const all: any;
  export = all;
  export const createClient: any;
  export const serve: any;
  export const crypto: any;
}
