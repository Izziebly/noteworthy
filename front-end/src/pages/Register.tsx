import { useState } from "react";
import type { SyntheticEvent } from "react";
import { useNavigate, Link } from "react-router-dom";
import { register } from "../services/authService";
import axios, { AxiosError } from "axios";
import "../styles/auth.css";

type RegisterPayload = { username: string; password: string };
type ApiError = { message?: string };

export default function RegisterPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const navigate = useNavigate();

  const handleSubmit = async (e: SyntheticEvent<HTMLFormElement, SubmitEvent>) => {
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

  return (
    <div className="auth-page">
      <div className="auth-card">

        {/* ── Brand ── */}
        <div className="auth-logo">
          <div className="auth-logo-mark">n</div>
          <span className="auth-logo-text">Noteworthy</span>
        </div>

        {/* ── Heading ── */}
        <h1 className="auth-heading">Create account</h1>
        <p className="auth-subheading">
          Start writing and organising your notes.
        </p>

        {/* ── Error ── */}
        {error && (
          <div className="error-banner" style={{ marginBottom: 20 }}>
            ⚠️ {error}
          </div>
        )}

        {/* ── Form ── */}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Username</label>
            <input
              className="form-input"
              type="text"
              placeholder="Choose a username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              autoComplete="username"
              required
              autoFocus
            />
          </div>

          <div className="form-group">
            <label className="form-label">Password</label>
            <div className="input-wrapper">
              <input
                className="form-input"
                type={showPassword ? "text" : "password"}
                placeholder="At least 6 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="new-password"
                minLength={6}
                required
              />
              <button
                type="button"
                className="input-eye-btn"
                onClick={() => setShowPassword((prev) => !prev)}
                tabIndex={-1}
              >
                {showPassword ? "🙈" : "👁️"}
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary btn-full btn-lg"
            style={{ marginTop: 8 }}
            disabled={loading}
          >
            {loading ? "Creating account..." : "Create Account"}
          </button>
        </form>

        {/* ── Login link ── */}
        <div className="auth-footer">
          Already have an account?{" "}
          <Link to="/login">Sign in</Link>
        </div>

      </div>
    </div>
  );
}