import API from "./axios";

export const request = async <T>(
  method: "get" | "post" | "put" | "delete",
  url: string,
  data?: unknown
): Promise<T> => {
  const res = await API({
    method,
    url,
    data,
  });

  return res.data;
};