import type { NextPage } from "next";
import Layout from "../layouts/layout";
import { useAccount } from "wagmi";
import TokenCreationForm from "../components/TokenCreationForm";

const Home: NextPage = () => {
  const { isConnected } = useAccount();

  return (
    <Layout>
      {isConnected ? (
        <TokenCreationForm />
      ) : (
        <div>Start by connecting your wallet.</div>
      )}
    </Layout>
  );
};

export default Home;
