{ config, lib, pkgs, ... }:
let
test = pkgs.writeText "peertube.yaml" "
listen:
  hostname: 'localhost'
  port: 9000

# Correspond to your reverse proxy server_name/listen configuration (i.e., your public PeerTube instance URL)
webserver:
  https: true
  hostname: 'video.pi.example.org'
  port: 443

rates_limit:
  api:
    # 50 attempts in 10 seconds
    window: 10 seconds
    max: 50
  login:
    # 15 attempts in 5 min
    window: 5 minutes
    max: 15
  signup:
    # 2 attempts in 5 min (only succeeded attempts are taken into account)
    window: 5 minutes
    max: 2
  ask_send_email:
    # 3 attempts in 5 min
    window: 5 minutes
    max: 3

# Proxies to trust to get real client IP
# If you run PeerTube just behind a local proxy (nginx), keep 'loopback'
# If you run PeerTube behind a remote proxy, add the proxy IP address (or subnet)
trust_proxy:
  - 'loopback'

# Your database name will be database.name OR \"peertube\"+database.suffix
database:
  hostname: 'localhost'
  port: 5432
  ssl: false
  suffix: '_prod'
  username: 'peertube'
  password: 'peertube'
  pool:
    max: 5

# Redis server for short time storage
# You can also specify a 'socket' path to a unix socket but first need to
# comment out hostname and port
redis:
  hostname: 'localhost'
  port: 6379
  auth: null
  db: 0

# SMTP server to send emails
smtp:
  # smtp or sendmail
  transport: smtp
  # Path to sendmail command. Required if you use sendmail transport
  sendmail: null
  hostname: null
  port: 465 # If you use StartTLS: 587
  username: null
  password: null
  tls: true # If you use StartTLS: false
  disable_starttls: false
  ca_file: null # Used for self signed certificates
  from_address: 'admin@example.com'

email:
  body:
    signature: \"PeerTube\"
  subject:
    prefix: \"[PeerTube]\"

# From the project root directory
storage:
  tmp: '/var/lib/peertube/storage/tmp/' # Use to download data (imports etc), store uploaded files before processing...
  avatars: '/var/lib/peertube/storage/avatars/'
  videos: '/var/lib/peertube/storage/videos/'
  streaming_playlists: '/var/lib/peertube/storage/streaming-playlists/'
  redundancy: '/var/lib/peertube/storage/redundancy/'
  logs: '/var/lib/peertube/storage/logs/'
  previews: '/var/lib/peertube/storage/previews/'
  thumbnails: '/var/lib/peertube/storage/thumbnails/'
  torrents: '/var/lib/peertube/storage/torrents/'
  captions: '/var/lib/peertube/storage/captions/'
  cache: '/var/lib/peertube/storage/cache/'
  plugins: '/var/lib/peertube/storage/plugins/'
  # Overridable client files : logo.svg, favicon.png and icons/*.png (PWA) in client/dist/assets/images
  # Could contain for example assets/images/favicon.png
  # If the file exists, peertube will serve it
  # If not, peertube will fallback to the default fil
  client_overrides: '/var/lib/peertube/storage/client-overrides/'

log:
  level: 'info' # debug/info/warning/error
  rotation:
    enabled : true # Enabled by default, if disabled make sure that 'storage.logs' is pointing to a folder handled by logrotate
    maxFileSize: 12MB
    maxFiles: 20
  anonymizeIP: false
  log_ping_requests: true
  prettify_sql: false

trending:
  videos:
    interval_days: 7 # Compute trending videos for the last x days
    algorithms:
      enabled:
        - 'best' # adaptation of Reddit's 'Best' algorithm (Hot minus History)
        - 'hot' # adaptation of Reddit's 'Hot' algorithm
        - 'most-viewed' # default, used initially by PeerTube as the trending page
        - 'most-liked'
      default: 'most-viewed'

# Cache remote videos on your server, to help other instances to broadcast the video
# You can define multiple caches using different sizes/strategies
# Once you have defined your strategies, choose which instances you want to cache in admin -> manage follows -> following
redundancy:
  videos:
    check_interval: '1 hour' # How often you want to check new videos to cache
    strategies: # Just uncomment strategies you want
#      -
#        size: '10GB'
#        # Minimum time the video must remain in the cache. Only accept values > 10 hours (to not overload remote instances)
#        min_lifetime: '48 hours'
#        strategy: 'most-views' # Cache videos that have the most views
#      -
#        size: '10GB'
#        # Minimum time the video must remain in the cache. Only accept values > 10 hours (to not overload remote instances)
#        min_lifetime: '48 hours'
#        strategy: 'trending' # Cache trending videos
#      -
#        size: '10GB'
#        # Minimum time the video must remain in the cache. Only accept values > 10 hours (to not overload remote instances)
#        min_lifetime: '48 hours'
#        strategy: 'recently-added' # Cache recently added videos
#        min_views: 10 # Having at least x views

# Other instances that duplicate your content
remote_redundancy:
  videos:
    # 'nobody': Do not accept remote redundancies
    # 'anybody': Accept remote redundancies from anybody
    # 'followings': Accept redundancies from instance followings
    accept_from: 'anybody'

csp:
  enabled: false
  report_only: true # CSP directives are still being tested, so disable the report only mode at your own risk!
  report_uri:

tracker:
  # If you disable the tracker, you disable the P2P aspect of PeerTube
  enabled: true
  # Only handle requests on your videos.
  # If you set this to false it means you have a public tracker.
  # Then, it is possible that clients overload your instance with external torrents
  private: true
  # Reject peers that do a lot of announces (could improve privacy of TCP/UDP peers)
  reject_too_many_announces: false

history:
  videos:
    # If you want to limit users videos history
    # -1 means there is no limitations
    # Other values could be '6 months' or '30 days' etc (PeerTube will periodically delete old entries from database)
    max_age: -1

views:
  videos:
    # PeerTube creates a database entry every hour for each video to track views over a period of time
    # This is used in particular by the Trending page
    # PeerTube could remove old remote video views if you want to reduce your database size (video view counter will not be altered)
    # -1 means no cleanup
    # Other values could be '6 months' or '30 days' etc (PeerTube will periodically delete old entries from database)
    remote:
      max_age: '30 days'

plugins:
  # The website PeerTube will ask for available PeerTube plugins and themes
  # This is an unmoderated plugin index, so only install plugins/themes you trust
  index:
    enabled: true
    check_latest_versions_interval: '12 hours' # How often you want to check new plugins/themes versions
    url: 'https://packages.joinpeertube.org'

federation:
  videos:
    federate_unlisted: false

    # Add a weekly job that cleans up remote AP interactions on local videos (shares, rates and comments)
    # It removes objects that do not exist anymore, and potentially fix their URLs
    # This setting is opt-in because due to an old bug in PeerTube, remote rates sent by instance before PeerTube 3.0 will be deleted
    # We still suggest you to enable this setting even if your users will loose most of their video's likes/dislikes
    cleanup_remote_interactions: false


###############################################################################
#
# From this point, all the following keys can be overridden by the web interface
# (local-production.json file). If you need to change some values, prefer to
# use the web interface because the configuration will be automatically
# reloaded without any need to restart PeerTube.
#
# /!\\ If you already have a local-production.json file, the modification of the
# following keys will have no effect /!\\.
#
###############################################################################

cache:
  previews:
    size: 500 # Max number of previews you want to cache
  captions:
    size: 500 # Max number of video captions/subtitles you want to cache
  torrents:
    size: 500 # Max number of video torrents you want to cache

admin:
  # Used to generate the root user at first startup
  # And to receive emails from the contact form
  email: 'admin@example.com'

contact_form:
  enabled: true

signup:
  enabled: false
  limit: 10 # When the limit is reached, registrations are disabled. -1 == unlimited
  requires_email_verification: false
  filters:
    cidr: # You can specify CIDR ranges to whitelist (empty = no filtering) or blacklist
      whitelist: []
      blacklist: []

user:
  # Default value of maximum video BYTES the user can upload (does not take into account transcoded files).
  # -1 == unlimited
  video_quota: -1
  video_quota_daily: -1

# If enabled, the video will be transcoded to mp4 (x264) with \"faststart\" flag
# In addition, if some resolutions are enabled the mp4 video file will be transcoded to these new resolutions.
# Please, do not disable transcoding since many uploaded videos will not work
transcoding:
  enabled: true

  # Allow your users to upload .mkv, .mov, .avi, .wmv, .flv, .f4v, .3g2, .3gp, .mts, m2ts, .mxf, .nut videos
  allow_additional_extensions: true

  # If a user uploads an audio file, PeerTube will create a video by merging the preview file and the audio file
  allow_audio_files: true

  # Amount of threads used by ffmpeg for 1 transcoding job
  threads: 1
  # Amount of transcoding jobs to execute in parallel
  concurrency: 1

  # Choose the transcoding profile
  # New profiles can be added by plugins
  # Available in core PeerTube: 'default'
  profile: 'default'

  resolutions: # Only created if the original video has a higher resolution, uses more storage!
    0p: true # audio-only (creates mp4 without video stream, always created when enabled)
    240p: false
    360p: false
    480p: true
    720p: false
    1080p: false
    1440p: false
    2160p: false

  # Generate videos in a WebTorrent format (what we do since the first PeerTube release)
  # If you also enabled the hls format, it will multiply videos storage by 2
  # If disabled, breaks federation with PeerTube instances < 2.1
  webtorrent:
    enabled: true

  # /!\\ Requires ffmpeg >= 4.1
  # Generate HLS playlists and fragmented MP4 files. Better playback than with WebTorrent:
  #     * Resolution change is smoother
  #     * Faster playback in particular with long videos
  #     * More stable playback (less bugs/infinite loading)
  # If you also enabled the webtorrent format, it will multiply videos storage by 2
  hls:
    enabled: false

live:
  enabled: false

  # Limit lives duration
  # -1 == unlimited
  max_duration: -1 # For example: '5 hours'

  # Limit max number of live videos created on your instance
  # -1 == unlimited
  max_instance_lives: 20

  # Limit max number of live videos created by a user on your instance
  # -1 == unlimited
  max_user_lives: 3

  # Allow your users to save a replay of their live
  # PeerTube will transcode segments in a video file
  # If the user daily/total quota is reached, PeerTube will stop the live
  # /!\\ transcoding.enabled (and not live.transcoding.enabled) has to be true to create a replay
  allow_replay: true

  # Your firewall should accept traffic from this port in TCP if you enable live
  rtmp:
    port: 1935

  # Allow to transcode the live streaming in multiple live resolutions
  transcoding:
    enabled: true
    threads: 2

    # Choose the transcoding profile
    # New profiles can be added by plugins
    # Available in core PeerTube: 'default'
    profile: 'default'

    resolutions:
      240p: false
      360p: false
      480p: true
      720p: false
      1080p: false
      1440p: false
      2160p: false

import:
  # Add ability for your users to import remote videos (from YouTube, torrent...)
  videos:
    # Amount of import jobs to execute in parallel
    concurrency: 1

    http: # Classic HTTP or all sites supported by youtube-dl https://rg3.github.io/youtube-dl/supportedsites.html
      enabled: false

      # IPv6 is very strongly rate-limited on most sites supported by youtube-dl
      force_ipv4: false

      # You can use an HTTP/HTTPS/SOCKS proxy with youtube-dl
      proxy:
        enabled: false
        url: \"\"
    torrent: # Magnet URI or torrent file (use classic TCP/UDP/WebSeed to download the file)
      enabled: false

auto_blacklist:
  # New videos automatically blacklisted so moderators can review before publishing
  videos:
    of_users:
      enabled: false

# Instance settings
instance:
  name: 'PeerTube'
  short_description: 'PeerTube, an ActivityPub-federated video streaming platform using P2P directly in your web browser.'
  description: 'Welcome to this PeerTube instance!' # Support markdown
  terms: 'No terms for now.' # Support markdown
  code_of_conduct: '' # Supports markdown

  # Who moderates the instance? What is the policy regarding NSFW videos? Political videos? etc
  moderation_information: '' # Supports markdown

  # Why did you create this instance?
  creation_reason: '' # Supports Markdown

  # Who is behind the instance? A single person? A non profit?
  administrator: '' # Supports Markdown

  # How long do you plan to maintain this instance?
  maintenance_lifetime: '' # Supports Markdown

  # How will you pay the PeerTube instance server? With your own funds? With users donations? Advertising?
  business_model: '' # Supports Markdown

  # If you want to explain on what type of hardware your PeerTube instance runs
  # Example: \"2 vCore, 2GB RAM...\"
  hardware_information: '' # Supports Markdown

  # What are the main languages of your instance? To interact with your users for example
  # Uncomment or add the languages you want
  # List of supported languages: https://peertube.cpy.re/api/v1/videos/languages
  languages:
    - en
    - de

  # You can specify the main categories of your instance (dedicated to music, gaming or politics etc)
  # Uncomment or add the category ids you want
  # List of supported categories: https://peertube.cpy.re/api/v1/videos/categories
  categories:
#    - 1  # Music
#    - 2  # Films
#    - 3  # Vehicles
#    - 4  # Art
#    - 5  # Sports
#    - 6  # Travels
#    - 7  # Gaming
#    - 8  # People
#    - 9  # Comedy
#    - 10 # Entertainment
#    - 11 # News & Politics
#    - 12 # How To
#    - 13 # Education
#    - 14 # Activism
#    - 15 # Science & Technology
#    - 16 # Animals
#    - 17 # Kids
#    - 18 # Food

  default_client_route: '/videos/trending'

  # Whether or not the instance is dedicated to NSFW content
  # Enabling it will allow other administrators to know that you are mainly federating sensitive content
  # Moreover, the NSFW checkbox on video upload will be automatically checked by default
  is_nsfw: false
  # By default, \"do_not_list\" or \"blur\" or \"display\" NSFW videos
  # Could be overridden per user with a setting
  default_nsfw_policy: 'do_not_list'

  customizations:
    javascript: '' # Directly your JavaScript code (without <script> tags). Will be eval at runtime
    css: '' # Directly your CSS code (without <style> tags). Will be injected at runtime
  # Robot.txt rules. To disallow robots to crawl your instance and disallow indexation of your site, add '/' to \"Disallow:'
  robots: |
    User-agent: *
    Disallow:
  # Security.txt rules. To discourage researchers from testing your instance and disable security.txt integration, set this to an empty string.
  securitytxt:
    \"# If you would like to report a security issue\\n# you may report it to:\\nContact: https://github.com/Chocobozzz/PeerTube/blob/develop/SECURITY.md\\nContact: mailto:\"

services:
  # Cards configuration to format video in Twitter
  twitter:
    username: '@Chocobozzz' # Indicates the Twitter account for the website or platform on which the content was published
    # If true, a video player will be embedded in the Twitter feed on PeerTube video share
    # If false, we use an image link card that will redirect on your PeerTube instance
    # Change it to \"true\", and then test on https://cards-dev.twitter.com/validator to see if you are whitelisted
    whitelisted: false

followers:
  instance:
    # Allow or not other instances to follow yours
    enabled: true
    # Whether or not an administrator must manually validate a new follower
    manual_approval: false

followings:
  instance:
    # If you want to automatically follow back new instance followers
    # If this option is enabled, use the mute feature instead of deleting followings
    # /!\\ Don't enable this if you don't have a reactive moderation team /!\\
    auto_follow_back:
      enabled: false

    # If you want to automatically follow instances of the public index
    # If this option is enabled, use the mute feature instead of deleting followings
    # /!\\ Don't enable this if you don't have a reactive moderation team /!\\
    auto_follow_index:
      enabled: false
      # Host your own using https://framagit.org/framasoft/peertube/instances-peertube#peertube-auto-follow
      index_url: ''

theme:
  default: 'default'

broadcast_message:
  enabled: false
  message: '' # Support markdown
  level: 'info' # 'info' | 'warning' | 'error'
  dismissable: false

search:
  # Add ability to fetch remote videos/actors by their URI, that may not be federated with your instance
  # If enabled, the associated group will be able to \"escape\" from the instance follows
  # That means they will be able to follow channels, watch videos, list videos of non followed instances
  remote_uri:
    users: true
    anonymous: false

  # Use a third party index instead of your local index, only for search results
  # Useful to discover content outside of your instance
  # If you enable search_index, you must enable remote_uri search for users
  # If you do not enable remote_uri search for anonymous user, your instance will redirect the user on the origin instance
  # instead of loading the video locally
  search_index:
    enabled: false
    # URL of the search index, that should use the same search API and routes
    # than PeerTube: https://docs.joinpeertube.org/api-rest-reference.html
    # You should deploy your own with https://framagit.org/framasoft/peertube/search-index,
    # and can use https://search.joinpeertube.org/ for tests, but keep in mind the latter is an unmoderated search index
    url: ''
    # You can disable local search, so users only use the search index
    disable_local_search: false
    # If you did not disable local search, you can decide to use the search index by default
    is_default_search: false
";
in
{
  # https://github.com/NixOS/nixpkgs/pull/106492/files#diff-4777ecc9c39f65314c4616d1287b6082fac99fefff66fe2251688dbf467ffca3
  services.peertube = {
    enable = true;
    database = {
      createLocally = true;
    };
    redis = {
      createLocally = true;  
    };
    # https://github.com/Chocobozzz/PeerTube/blob/develop/config/production.yaml.example
    configFile = test;
    # nix shell nixpkgs#nodejs-12_x
    # ls /nix/store/*-peertube-*/
    # cd /nix/store/acqg81dwab69897j1b4nzxx34ivflkz2-peertube-3.0.1/
    # sudo -u peertube NODE_CONFIG_DIR=/var/lib/peertube/config NODE_ENV=production npm run reset-password -- -u root

    # username: root
    # password: specified
  };

  networking.firewall.allowedTCPPorts = [ 1935 ]; # rtmp

  services.nginx = {
    virtualHosts = {
      "nginx-video.pi.example.org" = {
        serverName = "video.pi.example.org";
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:9000";
        };
      };
    };
  };
}