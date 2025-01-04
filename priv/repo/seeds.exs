# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Beabadooble.Repo.insert!(%Beabadooble.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Beabadooble.Repo.insert_all(
  Beabadooble.Schema.Songs,
  [
    %{id: 1, name: "Soren", filename: "Soren - Beabadoobee.mp3", seconds: 241},
    %{id: 2, name: "Ripples", filename: "Ripples - Beabadoobee.mp3", seconds: 187},
    %{id: 3, name: "Tired", filename: "Tired - Beabadoobee.mp3", seconds: 199},
    %{
      id: 4,
      name: "A Night To Remember",
      filename: "A Night To Remember - Beabadoobee.mp3",
      seconds: 233
    },
    %{
      id: 5,
      name: "tinkerbell is overrated",
      filename: "tinkerbell is overrated feat. PinkPantheress - Beabadoobee.mp3",
      seconds: 228
    },
    %{
      id: 6,
      name: "Last Day On Earth",
      filename: "Last Day On Earth - Beabadoobee.mp3",
      seconds: 222
    },
    %{id: 7, name: "Care", filename: "Care - Beabadoobee.mp3", seconds: 195},
    %{id: 8, name: "1999", filename: "1999 - Beabadoobee.mp3", seconds: 191},
    %{id: 9, name: "Dance with Me", filename: "Dance with Me - Beabadoobee.mp3", seconds: 234},
    %{id: 10, name: "Girl Song", filename: "Girl Song - Beabadoobee.mp3", seconds: 236},
    %{id: 11, name: "Eighteen", filename: "Eighteen - Beabadoobee.mp3", seconds: 238},
    %{id: 12, name: "See you Soon", filename: "See you Soon - Beabadoobee.mp3", seconds: 206},
    %{id: 13, name: "Coffee", filename: "Coffee - Beabadoobee.mp3", seconds: 126},
    %{
      id: 14,
      name: "the way things go",
      filename: "the way things go - Beabadoobee.mp3",
      seconds: 187
    },
    %{id: 15, name: "Horen Sarrison", filename: "Horen Sarrison - Beabadoobee.mp3", seconds: 335},
    %{id: 16, name: "Together", filename: "Together - Beabadoobee.mp3", seconds: 200},
    %{
      id: 17,
      name: "He Gets Me So High",
      filename: "He Gets Me So High - Beabadoobee.mp3",
      seconds: 165
    },
    %{id: 18, name: "If You Want To", filename: "If You Want To - Beabadoobee.mp3", seconds: 223},
    %{id: 19, name: "Talk", filename: "Talk - Beabadoobee.mp3", seconds: 158},
    %{id: 20, name: "Angel", filename: "Angel - Beabadoobee.mp3", seconds: 193},
    %{
      id: 21,
      name: "the perfect pair",
      filename: "the perfect pair - Beabadoobee.mp3",
      seconds: 177
    },
    %{id: 22, name: "Disappear", filename: "Disappear - Beabadoobee.mp3", seconds: 248},
    %{id: 23, name: "Spacing Out", filename: "Spacing Out - Beabadoobee.mp3", seconds: 100},
    %{id: 24, name: "Sunny day", filename: "Sunny day - Beabadoobee.mp3", seconds: 160},
    %{id: 25, name: "Take A Bite", filename: "Take A Bite - Beabadoobee.mp3", seconds: 158},
    %{id: 26, name: "Emo Song", filename: "Emo Song - Beabadoobee.mp3", seconds: 218},
    %{id: 27, name: "broken cd", filename: "broken cd - Beabadoobee.mp3", seconds: 170},
    %{id: 28, name: "Worth It", filename: "Worth It - Beabadoobee.mp3", seconds: 194},
    %{id: 29, name: "The Moon Song", filename: "The Moon Song - Beabadoobee.mp3", seconds: 141},
    %{id: 30, name: "Charlie Brown", filename: "Charlie Brown - Beabadoobee.mp3", seconds: 152},
    %{
      id: 31,
      name: "Yoshimi, Forest, Magdalene",
      filename: "Yoshimi, Forest, Magdalene - Beabadoobee.mp3",
      seconds: 204
    },
    %{id: 32, name: "She Plays Bass", filename: "She Plays Bass - Beabadoobee.mp3", seconds: 207},
    %{id: 33, name: "Cologne", filename: "Cologne - Beabadoobee.mp3", seconds: 164},
    %{id: 34, name: "10:36", filename: "10_36 - Beabadoobee.mp3", seconds: 195},
    %{
      id: 35,
      name: "The Man Who Left Too Soon",
      filename: "The Man Who Left Too Soon - Beabadoobee.mp3",
      seconds: 109
    },
    %{id: 36, name: "Beaches", filename: "Beaches - Beabadoobee.mp3", seconds: 230},
    %{id: 37, name: "Art Class", filename: "Art Class - Beabadoobee.mp3", seconds: 247},
    %{id: 38, name: "Animal Noises", filename: "Animal Noises - Beabadoobee.mp3", seconds: 214},
    %{id: 39, name: "Sun More Often", filename: "Sun More Often - Beabadoobee.mp3", seconds: 241},
    %{
      id: 40,
      name: "How Was Your Day?",
      filename: "How Was Your Day_ - Beabadoobee.mp3",
      seconds: 260
    },
    %{
      id: 41,
      name: "This Is How It Went",
      filename: "This Is How It Went - Beabadoobee.mp3",
      seconds: 214
    },
    %{id: 42, name: "Sorry", filename: "Sorry - Beabadoobee.mp3", seconds: 233},
    %{id: 43, name: "Ever Seen", filename: "Ever Seen - Beabadoobee.mp3", seconds: 203},
    %{id: 44, name: "Everest", filename: "Everest - Beabadoobee.mp3", seconds: 158},
    %{id: 45, name: "Are You Sure", filename: "Are You Sure - Beabadoobee.mp3", seconds: 244},
    %{id: 46, name: "Lovesong", filename: "Lovesong - Beabadoobee.mp3", seconds: 245},
    %{id: 47, name: "Ceilings", filename: "Ceilings - Beabadoobee.mp3", seconds: 240},
    %{id: 48, name: "Bobby", filename: "Bobby - Beabadoobee.mp3", seconds: 205},
    %{id: 49, name: "Dye It Red", filename: "Dye It Red - Beabadoobee.mp3", seconds: 189},
    %{id: 50, name: "fairy song", filename: "fairy song - Beabadoobee.mp3", seconds: 164},
    %{
      id: 51,
      name: "Everything I Want",
      filename: "Everything I Want - Beabadoobee.mp3",
      seconds: 191
    },
    %{id: 52, name: "Post", filename: "Post - Beabadoobee.mp3", seconds: 161},
    %{id: 53, name: "Glue Song", filename: "Glue Song - Beabadoobee.mp3", seconds: 135},
    %{id: 54, name: "Angry Song", filename: "Angry Song - Beabadoobee.mp3", seconds: 68},
    %{
      id: 55,
      name: "Winter Wonderland",
      filename: "Winter Wonderland - Beabadoobee.mp3",
      seconds: 182
    },
    %{id: 56, name: "Tie My Shoes", filename: "Tie My Shoes - Beabadoobee.mp3", seconds: 178},
    %{id: 57, name: "A Cruel Affair", filename: "A Cruel Affair - Beabadoobee.mp3", seconds: 152},
    %{
      id: 58,
      name: "You’re here that’s the thing",
      filename: "You’re here that’s the thing - Beabadoobee.mp3",
      seconds: 198
    },
    %{id: 59, name: "Back To Mars", filename: "Back To Mars - Beabadoobee.mp3", seconds: 90},
    %{
      id: 60,
      name: "It's Only A Paper Moon",
      filename: "It's Only A Paper Moon - Beabadoobee.mp3",
      seconds: 145
    },
    %{id: 61, name: "Real Man", filename: "Real Man - Beabadoobee.mp3", seconds: 160},
    %{
      id: 62,
      name: "You Lie All The Time",
      filename: "You Lie All The Time - Beabadoobee.mp3",
      seconds: 251
    },
    %{id: 63, name: "Home Alone", filename: "Home Alone - Beabadoobee.mp3", seconds: 140},
    %{
      id: 64,
      name: "Don’t get the deal",
      filename: "Don’t get the deal - Beabadoobee.mp3",
      seconds: 220
    },
    %{id: 65, name: "Apple Cider", filename: "Apple Cider - Beabadoobee.mp3", seconds: 178},
    %{id: 66, name: "Further Away", filename: "Further Away - Beabadoobee.mp3", seconds: 187},
    %{id: 67, name: "One Time", filename: "One Time - Beabadoobee.mp3", seconds: 184},
    %{id: 68, name: "Pictures of Us", filename: "Pictures of Us - Beabadoobee.mp3", seconds: 279},
    %{
      id: 69,
      name: "Beatopia Cultsong",
      filename: "Beatopia Cultsong - Beabadoobee.mp3",
      seconds: 151
    },
    %{
      id: 70,
      name: "The Way I Spoke",
      filename: "The Way I Spoke - Beabadoobee.mp3",
      seconds: 255
    },
    %{id: 71, name: "California", filename: "California - Beabadoobee.mp3", seconds: 172},
    %{
      id: 72,
      name: "I Wish I Was Stephen Malkmus",
      filename: "I Wish I Was Stephen Malkmus - Beabadoobee.mp3",
      seconds: 231
    },
    %{id: 73, name: "Coming Home", filename: "Coming Home - Beabadoobee.mp3", seconds: 135},
    %{id: 74, name: "Susie May", filename: "Susie May - Beabadoobee.mp3", seconds: 266},
    %{id: 75, name: "Space Cadet", filename: "Space Cadet - Beabadoobee.mp3", seconds: 264}
  ],
  on_conflict: :nothing
)
