import type { NextPage } from "next";
import Layout from "../layouts/layout";
import { useAccount } from "wagmi";
import TokenCreationForm from "../components/TokenCreationForm";

const Home: NextPage = () => {
  const { isConnected } = useAccount();

  return (
    <Layout>{isConnected ? <TokenCreationForm /> : <div>Salut !</div>}</Layout>
  );
};

export default Home;
