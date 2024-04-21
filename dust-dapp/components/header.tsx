import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function Header() {
  return (
    <div className="w-full flex justify-between items-center">
      <h1 className="font-bold">Memecoin Cooker !</h1>
      <ConnectButton />
    </div>
  );
}
