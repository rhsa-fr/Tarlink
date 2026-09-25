import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "tarlink-pantura-super-secret-jwt-key-2026";

export interface TokenPayload {
  userId: string;
  phone: string;
  role: "customer" | "group_leader" | "admin";
  name?: string;
}

export function generateToken(payload: TokenPayload): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: "30d" });
}

export function verifyToken(token: string): TokenPayload | null {
  try {
    return jwt.verify(token, JWT_SECRET) as TokenPayload;
  } catch {
    return null;
  }
}
