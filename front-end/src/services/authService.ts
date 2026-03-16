import { request } from "../api/request";

interface AuthData {
  username: string;
  password: string;
}

export interface User {
  _id: string;
  username: string;
}

interface LoginResponse {
  user: User;
  accessToken: string;
}

export const register = (data: AuthData) =>
  request<{ message: string }>("post", "/auth/register", data);

export const login = (data: AuthData) =>
  request<LoginResponse>("post", "/auth/login", data);

export const logout = () =>
  request<{ message: string }>("post", "/auth/logout");

export const getCurrentUser = () =>
  request<User>("get", "/auth/me");