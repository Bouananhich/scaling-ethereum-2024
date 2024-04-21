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
  const { writeContract, data: hash, isPending } = useWriteContract();

  const { data, isLoading, isSuccess } = useWaitForTransactionReceipt({
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
            disabled={isPending || isLoading}
          >
            {(isPending || isLoading) && (
              <svg
                aria-hidden="true"
                role="status"
                className="inline mr-2 w-4 h-4 text-gray-200 animate-spin dark:text-gray-600"
                viewBox="0 0 100 101"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                  fill="currentColor"
                ></path>
                <path
                  d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                  fill="#1C64F2"
                ></path>
              </svg>
            )}
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
            <label>Initial Holders (separated by commas)</label>
            <input
              className="border border-slate-600 border-solid rounded"
              type="text"
              name="initialHolders"
              value={deployFormData.initialHolders}
              onChange={handleDeployFormChange}
            />
          </div>
          <div className="flex flex-col">
            <label>Initial Holders (separated by commas)</label>
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
            disabled={isPending || isLoading}
          >
            {(isPending || isLoading) && (
              <svg
                aria-hidden="true"
                role="status"
                className="inline mr-2 w-4 h-4 text-gray-200 animate-spin dark:text-gray-600"
                viewBox="0 0 100 101"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                  fill="currentColor"
                ></path>
                <path
                  d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                  fill="#1C64F2"
                ></path>
              </svg>
            )}
            Deploy Token on uniswap
          </button>
        </form>
      )}
    </div>
  );
}
