import { useState } from "react";
import type { SyntheticEvent } from "react";
import { useNavigate } from "react-router-dom";
import { login, register } from "../services/authService";
import { useAuth } from "../context/useAuth";
import axios, { AxiosError } from "axios";

type RegisterPayload = { username: string; password: string };
type ApiError = { message?: string };

/* LOGIN LOGIC */

export function useLogin() {
  const navigate = useNavigate();
  const { setUser, setAccessToken } = useAuth();

  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);
    try {
      const res = await login({ username, password });
      setUser(res.user);
      setAccessToken?.(res.accessToken);
      navigate("/notes");
    } catch (err: unknown) {
      const axErr = err as AxiosError<{ message: string }>;
      setError(axErr.response?.data?.message || "Login failed");
    } finally {
      setIsLoading(false);
    }
  };

  return {
    username,
    setUsername,
    password,
    setPassword,
    error,
    isLoading,
    showPassword,
    setShowPassword,
    handleSubmit,
  };
}

/* REGISTER LOGIC */

export function useRegister() {
  const navigate = useNavigate();

  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (
    e: SyntheticEvent<HTMLFormElement, SubmitEvent>
  ) => {
    e.preventDefault();
    if (loading) return;

    setError("");
    setLoading(true);

    try {
      await register({ username, password } as RegisterPayload);
      navigate("/login");
    } catch (err: unknown) {
      if (axios.isAxiosError(err)) {
        const axErr = err as AxiosError<ApiError>;
        setError(axErr.response?.data?.message || "Registration failed");
      } else {
        setError("Registration failed");
      }
    } finally {
      setLoading(false);
    }
  };

  return {
    username,
    setUsername,
    password,
    setPassword,
    error,
    loading,
    showPassword,
    setShowPassword,
    handleSubmit,
  };
}