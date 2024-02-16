import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import { WagmiConfig, createConfig } from "wagmi";
import { createPublicClient, http } from 'viem'
import { scrollSepolia } from "wagmi/chains";
import {
  getDefaultWallets,
  RainbowKitProvider,
  darkTheme,
} from "@rainbow-me/rainbowkit";
import "@rainbow-me/rainbowkit/styles.css";


const { connectors } = getDefaultWallets({
  appName: "ZK Blind - Blind Verifier",
  chains: [scrollSepolia],
  projectId: "b68298f4e6597f970ac06be1aea7998d",
});

const config = createConfig({
  autoConnect: true,
  publicClient: createPublicClient({
    chain: scrollSepolia,
    transport: http()
  }),
  connectors: connectors,
})
 

ReactDOM.render(
  <React.StrictMode>
    <WagmiConfig config={config}>
      <RainbowKitProvider chains={[scrollSepolia]} theme={darkTheme()}>
        <App />
      </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>,
  document.getElementById("root")
);
