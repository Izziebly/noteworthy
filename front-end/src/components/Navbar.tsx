import { useNavigate } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { useAuth } from "../context/useAuth";
import "../styles/navbar.css";

export default function Navbar() {
  const { user, logoutUser } = useAuth();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  /* ── Logout ── */
  const handleLogout = async () => {
    try {
      await logoutUser();
    } finally {
      queryClient.clear();
      navigate("/login");
    }
  };

  return (
    <nav className="navbar">
      <div className="navbar-inner">

        <div className="navbar-brand">
          <div className="navbar-logo">n</div>
          <span className="navbar-title">Noteworthy</span>
        </div>

        <div className="navbar-actions">
          {user && (
            <span className="navbar-user">@{user.username}</span>
          )}
          <button className="btn btn-logout" onClick={handleLogout}>
            Logout
          </button>
        </div>

      </div>
    </nav>
  );
}