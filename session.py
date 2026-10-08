from pyrogram import Client

api_id = 37686686
api_hash = "623385f0e9f59db0514856da25aa2f5e"

app = Client("my_session", api_id=api_id, api_hash=api_hash)

async def main():
    async with app:
        print("\n\nYOUR SESSION STRING IS:\n")
        print(await app.export_session_string())
        print("\n")

app.run(main())

