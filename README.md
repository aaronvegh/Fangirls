### Fangirls
*Updated November, 2021!* Fangirls is now based on the successor to Youtube-DL, yt-dlp. It also includes far-better video support, downloading more reliably, and with better progress information. Finally, it allows you to cancel and remove downloads. I was so impressed with myself, I up'd the version to 2.0. 🙌🏻

---

Fangirls is a super-simple front-end to the [https://github.com/yt-dlp/yt-dlp](yt-dlp project). In short, it grabs the source of videos you watch on the web, and downloads them to your computer. Despite the name, yt-dlp supports vastly more services than YouTube — [https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md](you can see a full list). It's also a pretty active project; if there's a site that it doesn't work for, the developers are willing to take requests.

One problem with yt-dlp is that it's a Python app that you have to use from the command line. I love the command line as much as any card-carrying nerd, but I wanted to build a quick Mac app, and this seemed like a good opportunity.

Here's a picture of Fangirls in action:

<img src="https://github.com/aaronvegh/Fangirls/raw/gh-pages/fangirls.png" alt="Fangirls" />

### Features
Paste in the URL of a web page that contains a video, and Fangirls will use an included copy of yt-dlp to pull the video data from that page and download what it finds. In bullet form, then:

* Download videos from the sites that youtube-dl supports;
* Choose your download location
* ...what else do you even need?

### Why "Fangirls"?
It's a word my 12-year-old daughter was using a lot when I originally built this, both as a noun and (more entertainingly) a verb. It's interchangeably a derogation and word of praise. And it was on my mind when I sat at the New Project dialogue in Xcode.

### Who designed your amazing app icon?
Har, har. It was me.

### License
I'm releasing Fangirls under the [Creative Commons Attribution 4.0 license](https://creativecommons.org/licenses/by/4.0/). In short, you can do whatever you like with this code as long as you give me credit. Which brings me to...

### Contributions
I'd be happy to accept your PRs! Make a fork of this project and shoot me a pull request and let's make Fangirls truly fangirl-worthy.
