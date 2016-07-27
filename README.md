![Ticket Dash Logo](/Screenshots/AppIcon-sm.png?raw=true)

# Ticket-Dash
Ticket Dash is a fast paced quest-based game built on the SpriteKit framework. Developed for Catholic Central High School's Drive Event, the game takes place in the high school where the student (player) must collect as many tickets and finish as many quests in the allotted time.

## Preface
I almost didn't upload this project. Learning game development for the first time and having to create graphics and develop a game in under a month, keeping the code neat began to suffer. While the API calls fairly organized, the gameplay was all in one class. I decided to upload this project at this point (a year and a half later - I did not have version control at the time of the project) because under such confinements, I am proud of the final user experience and what myself and my project manager accomplished under such a short deadline. You can read the full story below.

![Main Menu](/Screenshots/Main_Menu.png?raw=true)
![Gameplay](/Screenshots/Game_Play_Chat.png?raw=true)

## Storytime!
A call came in from a friend, Scott, a few days after my freshman winter semester had started. He was still attending my alma mater, Detroit Catholic Central High School, at the time. He came to me with an exciting idea for an RPG iOS game where the main characters were teachers at the school. I loved the humor behind the idea and we spent hours on the phone batting ideas back and forth. Soon we decided to begin the project with myself as the sole developer and Scott was the PM of the project. We ended up splitting the graphic development 50/50. I was excited to begin, then he told me the deadline...we had a month to complete the project.

We looked for other Catholic Central students who had development experience or a graphic artist background, but to no avail. We trudged on down the path of development as a pair.

### Challanges Faced
With myself as the only developer, not having prior experience with the SpriteKit framework, and only a month to complete the project, this was to prove a challenge. Not only did we only have a month to complete the app, but we didn't have any prior graphics, sounds, or visuals. We had a month to create everything from the ground up. With constant revisions happening to the layout of the school's design, and new door and levels needing to be added, hard coding was not proving effective.

### The Solution
Scott began to take on more of the character and level design as I took on the user interfaces. In order to increase our productivity, allowing Scott to make graphical changes on the fly without affecting functionality, I devised a solution using JSON. Using custom formatted JSON, Scott was able to use coordinates from his photoshop designs to designate where doors would be placed, where walls (collisions) should be, and even where to place tickets in the map. This solution allowed us to continue developing the application and provide a much faster workflow between us. A shortened example of such JSON can be found below:
```JSON
{"Collision Objects": {
    "Walls":{
        "Wall1":{
            "position": [0,480],
            "size": [608,32]
        },
        
        "Wall2":{
            "position": [1216,480],
            "size": [576, 32]
        },
        
        "Wall3":{
            "position": [752,160],
            "size": [320,352]
        }
    },
    "Doors":{
        "Door1":{
            "position": [26,480],
            "size": [22,32],
            "name": "Stuart"
        },
		"Door2":{
            "position": [229,480],
            "size": [22,32],
            "name": "Gizmondi"
        }
    }
}}
```

### Deadlines
With the deadline quickly approaching in two weeks we made a lot of last second changes. Scrapping level designs and item collection functionality. To compensate we made short "quests" which players could do to earn more points. We also decided to make the game time trial based, giving a limited time to collect as many tickets as possible. The last two weeks were hectic. I almost didn't upload the project because I wasn't proud of what was the beginning of spaghetti code.

In the prior few weeks to completion I still had to add a scoreboard feature for both (internal) students and a global scoreboard. I decided to try something new with Apple's CloudKit for database storage. This was a mistake. Not only was it brand new and had little to no documentation, but I mistakenly changed the app's bundle identifier which caused a mess of issues with how Apple's CloudKit store's your app's data.

### In the End
In the end, I am happy with how the gameplay turned out for the extremely short deadline we had. It didn't have all the features we originally planned, but we made due in creating a fun time-trial game.

### Homage
If you run the source you'll notice the intro screen will flash between the game logo and a starry image of the number "33". Thirty three was the jersey number of David Widzinski, a fellow Catholic Central brother who had passed during our time in high school. Scott and I wanted to include a small homage to our fellow Catholic Central brother so we decided to include this in our design in the final days before release.
