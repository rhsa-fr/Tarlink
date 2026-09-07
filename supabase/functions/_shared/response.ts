export function successResponse(data: unknown, status = 200) {
  return new Response(
    JSON.stringify({ success: true, data }),
    { status, headers: { "Content-Type": "application/json" } }
  );
}

export function errorResponse(
  statusCode: number,
  message: string,
  error: string
) {
  return new Response(
    JSON.stringify({ statusCode, message, error }),
    { status: statusCode, headers: { "Content-Type": "application/json" } }
  );
}
