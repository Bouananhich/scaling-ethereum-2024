import { useEffect, useState } from "react";
import type { ChangeEvent, FormEvent } from "react";
import { useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { abi } from "../abi/abi";

export default function TokenCreationForm() {
  const [formData, setFormData] = useState({
    name: "",
    symbol: "",
    totalSupply: 100,
  });
  const [deployFormData, setDeployFormData] = useState<{
    initialPrice: number;
    initialHolders: Array<string>;
    initialAmounts: Array<string>;
  }>({
    initialPrice: 1000,
    initialHolders: [],
    initialAmounts: [],
  });
  const [createdTokenAddress, setCreatedTokenAddress] = useState<string>();
  const [tokenCreated, setTokenCreated] = useState<boolean>(false);
  const { writeContract, data: hash } = useWriteContract();

  const { data } = useWaitForTransactionReceipt({
    hash,
  });

  useEffect(() => {
    if (!tokenCreated && data?.logs[0]?.address) {
      setCreatedTokenAddress(data?.logs[0].address);
      setTokenCreated(true);
    }
  }, [data, tokenCreated]);

  const handleChange = (e: ChangeEvent<HTMLInputElement>): void => {
    const { name, value } = e.target;
    setFormData((prevState) => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleDeployFormChange = (e: ChangeEvent<HTMLInputElement>): void => {
    const { name, value } = e.target;
    let valueToArray: Array<string>;
    if (name === "initialHolders" || name === "initialAmounts") {
      valueToArray = value.split(",");
    }
    setDeployFormData((prevState) => ({
      ...prevState,
      [name]: valueToArray ?? value,
    }));
  };

  const triggerTokenCreationContract = () => {
    const totalSupplyWei = formData.totalSupply * 10 ** 18;

    writeContract({
      abi,
      address: "0x147bb33932f172C5C83e1124896A65fD04DbAd61",
      functionName: "cookMemecoin",
      args: [formData.name, formData.symbol, totalSupplyWei],
    });
  };

  const triggerTokenDeploymentContract = () => {
    const payableAmount = formData.totalSupply / deployFormData.initialPrice;
    const payableAmountWei = payableAmount * 10 ** 18;

    writeContract({
      abi,
      address: "0x147bb33932f172C5C83e1124896A65fD04DbAd61",
      functionName: "deploy_on_uniswapv2",
      args: [
        createdTokenAddress,
        deployFormData.initialHolders,
        deployFormData.initialAmounts.map((amount) => +amount * 10 ** 18),
      ],
      value: BigInt(payableAmountWei),
    });
  };

  const handleTokenCreationSubmit = (e: FormEvent<HTMLFormElement>): void => {
    e.preventDefault();
    triggerTokenCreationContract();
  };

  const handleDeploySubmit = (e: FormEvent<HTMLFormElement>): void => {
    e.preventDefault();
    triggerTokenDeploymentContract();
  };

  // TODO: Add validation on the form
  return (
    <div className="w-full flex flex-col justify-center items-center mt-[40px]">
      <ol className="mb-[16px] max-w-[400px] flex items-center w-full text-sm font-medium text-center text-gray-500 dark:text-gray-400 sm:text-base">
        <li
          className={`${
            createdTokenAddress ? "text-blue-600 dark:text-blue-500" : ""
          } flex md:w-full items-center sm:after:content-[''] after:w-full after:h-1 after:border-b after:border-gray-200 after:border-1 after:hidden sm:after:inline-block after:mx-1 xl:after:mx-2 dark:after:border-gray-700`}
        >
          <span className="flex items-center after:content-['/'] sm:after:hidden after:text-gray-200 dark:after:text-gray-500">
            {createdTokenAddress && (
              <svg
                className="w-3.5 h-3.5 sm:w-4 sm:h-4 me-2.5"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z" />
              </svg>
            )}
            Create <span className="hidden sm:inline-flex sm:ms-2">Token</span>
          </span>
        </li>
        <li className="flex flex-1 md:w-full items-center">
          <span className="flex items-center">
            Deploy{" "}
            <span className="hidden sm:inline-flex sm:ms-2">(uniswap)</span>
          </span>
        </li>
      </ol>

      {!createdTokenAddress && (
        <form
          className="w-full max-w-[400px] bg-white p-[32px] rounded-lg flex flex-col justify-center gap-3"
          onSubmit={handleTokenCreationSubmit}
        >
          <div className="flex flex-col">
            <label>Name</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
            />
          </div>
          <div className="flex flex-col">
            <label>Symbol</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="text"
              name="symbol"
              value={formData.symbol}
              onChange={handleChange}
            />
          </div>
          <div className="flex flex-col">
            <label>Total Supply</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="number"
              name="totalSupply"
              value={formData.totalSupply}
              onChange={handleChange}
            />
          </div>
          <button
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mt-[8px]"
            type="submit"
          >
            Create Token
          </button>
        </form>
      )}

      {createdTokenAddress && (
        <form
          className="w-full max-w-[400px] bg-white p-[32px] rounded-lg flex flex-col justify-center gap-3"
          onSubmit={handleDeploySubmit}
        >
          <div className="flex flex-col">
            <label>Initial Price</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="number"
              name="initialPrice"
              value={deployFormData.initialPrice}
              onChange={handleDeployFormChange}
            />
          </div>
          {deployFormData.initialPrice && (
            <p>
              Payable amount :
              {formData.totalSupply / deployFormData.initialPrice ?? 0}
            </p>
          )}
          <div className="flex flex-col">
            <label>Initial Holders (separated by comas)</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="text"
              name="initialHolders"
              value={deployFormData.initialHolders}
              onChange={handleDeployFormChange}
            />
          </div>
          <div className="flex flex-col">
            <label>Initial Holders (separated by comas)</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="text"
              name="initialAmounts"
              value={deployFormData.initialAmounts}
              onChange={handleDeployFormChange}
            />
          </div>
          <button
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mt-[8px]"
            type="submit"
          >
            Deploy Token on uniswap
          </button>
        </form>
      )}
    </div>
  );
}
