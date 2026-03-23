import { Navigate } from "react-router-dom";
import { useAuth } from "../context/useAuth";

export default function PublicRoute({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user } = useAuth();

  if (user) {
    return <Navigate to="/notes" replace />;
  }

  return children;
}