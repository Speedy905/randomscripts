import sys
import discord
from discord.ext.commands import Bot
from discord.ext import commands
import asyncio

Client = discord.Client() 
client = commands.Bot(command_prefix = "!") 

@client.event 
async def on_ready():
    print("on") 

@client.event
async def on_message(message):
    if message.content == "test":
        await client.send_message(message.channel, "test message")
    if message.content == 'test2':
        await client.send_message(message.channel, "test message 2")
    if message.content.startswith("!ping"):
        await client.send_message(message.channel, "pong")
    if message.content.startswith("!turnoff"):
        if "408462719235391489" in [role.id for role in message.author.roles]:
            sys.exit()
        else:
            await client.send_message(message.channel, "No permission")


client.run("NDA4NDI1NjQ1OTc5NDY3Nzk3.DVQMYA.gNl165KsKMiWJsbgszq0sb0w-sM") 
