import type { ReactNode } from "react";
import Header from "../components/header";
import styles from "../styles/Home.module.css";

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <div
      className={`w-screen h-screen flex flex-col px-4 pt-3 ${styles["custom-bg"]}`}
    >
      <Header />
      <main>{children}</main>
    </div>
  );
}
