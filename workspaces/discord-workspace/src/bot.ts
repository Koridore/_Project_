import { Client, ClientOptions } from "discord.js";
import { ready } from "./listeners/ready"

import interactionCreate from "./listeners/interactionCreate";

const token = "ODQyOTE0MjA1Mzk2MzY5NDc5.GkKeS9.qeD2s48wwLTtDpBLLMHiodAQfzGc689WDEwtqE"; // add your token here

console.log("Bot is starting...");

const client = new Client({
    intents: []
});

client.login(token);
//ready(client);
interactionCreate(client);

//console.log(client);