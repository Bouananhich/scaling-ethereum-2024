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
  const { writeContract, data: hash } = useWriteContract();

  // Test :
  const { data } = useWaitForTransactionReceipt({
    hash,
  });

  useEffect(() => {
    console.log("iciii : ", data);
  }, [data]);

  const handleChange = (e: ChangeEvent<HTMLInputElement>): void => {
    const { name, value } = e.target;
    setFormData((prevState) => ({
      ...prevState,
      [name]: value,
    }));
  };

  const triggerContract = () => {
    const totalSupplyWei = formData.totalSupply * 10 ** 18;

    writeContract({
      abi,
      address: "0x15C4203B2BEb705E3b909A23A3f08d1E244AcB9d",
      functionName: "cookMemecoin",
      args: [formData.name, formData.symbol, totalSupplyWei],
    });
  };

  const handleSubmit = (e: FormEvent<HTMLFormElement>): void => {
    e.preventDefault();
    triggerContract();
  };

  // TODO: Add validation on the form
  return (
    <div className="w-full flex justify-center mt-[40px]">
      <form
        className="w-full max-w-[400px] bg-white p-[32px] rounded-lg flex flex-col justify-center gap-2"
        onSubmit={handleSubmit}
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
          <label>Symbol:</label>
          <input
            className="border border-slate-600 border-solid rounded"
            type="text"
            name="symbol"
            value={formData.symbol}
            onChange={handleChange}
          />
        </div>
        <div className="flex flex-col">
          <label>Total Supply:</label>
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
          Submit
        </button>
      </form>
    </div>
  );
}
