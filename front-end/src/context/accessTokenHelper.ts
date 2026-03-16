import { AuthContext } from "./authContext";
import { useContext } from "react";

let accessTokenValue: string | null = null;

// Setter to update token from context
export const setAccessToken = (token: string) => {
  accessTokenValue = token;
};

// Getter for Axios
export const getAccessToken = () => {
  return accessTokenValue;
};

// React hook to sync with context in components
export const useAuthToken = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error("useAuthToken must be used inside AuthProvider");
  return [context.accessToken, context.setAccessToken] as const;
};