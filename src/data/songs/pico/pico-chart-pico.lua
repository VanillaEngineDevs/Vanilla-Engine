return {
    version = "2.0.0",
    scrollSpeed = {
        easy = 1.8,
        normal = 2.2,
        hard = 2.5,
    },
    events = {
        {
            t = 0,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 50,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 0.9,
            },
        },
        {
            t = 200,
            e = "SetCameraBop",
            v = {
                rate = 4,
                intensity = 0,
            },
        },
        {
            t = 3100,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 1,
            },
        },
        {
            t = 3200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 3250,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 9600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 11000,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 12600,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 14200,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 15800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 15900,
            e = "SetCameraBop",
            v = {
                rate = 4,
                intensity = 1,
            },
        },
        {
            t = 16000,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 22300,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 0.7,
            },
        },
        {
            t = 22400,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 27200,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 28800,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 80,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 28846,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.95,
                mode = "stage",
            },
        },
        {
            t = 35100,
            e = "SetCameraBop",
            v = {
                rate = 1,
                intensity = 0.7,
            },
        },
        {
            t = 35200,
            e = "FocusCamera",
            v = {
                x = 0,
                duration = 4,
                y = 0,
                char = 0,
                ease = "CLASSIC",
            },
        },
        {
            t = 35245,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1,
                mode = "stage",
            },
        },
        {
            t = 38400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 41500,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 1.2,
            },
        },
        {
            t = 41600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 41650,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 42600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 80,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 42646,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.95,
                mode = "stage",
            },
        },
        {
            t = 44400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 44800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 64,
                mode = "stage",
                zoom = 0.95,
            },
        },
        {
            t = 48000,
            e = "FocusCamera",
            v = {
                x = 0,
                duration = 4,
                y = 0,
                char = 0,
                ease = "CLASSIC",
            },
        },
        {
            t = 48045,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1,
                mode = "stage",
            },
        },
        {
            t = 50800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 51200,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 52800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 54300.1621621622,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 1.2,
            },
        },
        {
            t = 54450,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 55400,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 80,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 55446,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.95,
                mode = "stage",
            },
        },
        {
            t = 57200,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 57600,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 0.95,
            },
        },
        {
            t = 60800,
            e = "FocusCamera",
            v = {
                x = 0,
                duration = 4,
                y = 0,
                char = 0,
                ease = "CLASSIC",
            },
        },
        {
            t = 60845,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1,
                mode = "stage",
            },
        },
        {
            t = 63600,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 64000,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 65500,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 0,
            },
        },
        {
            t = 65800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 66150,
            e = "PlayAnimation",
            v = {
                force = false,
                anim = "burpShit",
                target = "boyfriend",
            },
        },
        {
            t = 66180,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 66550,
            e = "PlayAnimation",
            v = {
                force = false,
                anim = "shit",
                target = "boyfriend",
            },
        },
        {
            t = 66800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 67100,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 1.3,
            },
        },
        {
            t = 67200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 80,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 67246,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.95,
                mode = "stage",
            },
        },
        {
            t = 73600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 73645,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 75100,
            e = "SetCameraBop",
            v = {
                rate = 1,
                intensity = 0.8,
            },
        },
        {
            t = 75400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 76700,
            e = "SetCameraBop",
            v = {
                rate = 1,
                intensity = 0.4,
            },
        },
        {
            t = 77000,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 78400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 79900,
            e = "SetCameraBop",
            v = {
                rate = 4,
                intensity = 3,
            },
        },
        {
            t = 80000,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 64,
                mode = "stage",
                zoom = 0.9,
            },
        },
        {
            t = 80250,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 0.2,
            },
        },
    },
    notes = {
        easy = {
            {
                t = 3800,
                d = 7,
            },
            {
                t = 4000,
                d = 5,
            },
            {
                t = 4200,
                d = 4,
            },
            {
                t = 4600,
                d = 7,
            },
            {
                t = 5000,
                d = 4,
            },
            {
                t = 5400,
                d = 6,
            },
            {
                t = 5600,
                d = 5,
            },
            {
                t = 5800,
                d = 7,
            },
            {
                t = 6200,
                d = 5,
            },
            {
                t = 7000,
                d = 7,
            },
            {
                t = 7200,
                d = 5,
            },
            {
                t = 7400,
                d = 4,
            },
            {
                t = 7800,
                d = 7,
            },
            {
                t = 8200,
                d = 6,
            },
            {
                t = 8600,
                d = 4,
            },
            {
                t = 8800,
                d = 5,
            },
            {
                t = 9000,
                d = 7,
            },
            {
                t = 9400,
                d = 5,
            },
            {
                t = 10200,
                d = 0,
            },
            {
                t = 10400,
                d = 3,
            },
            {
                t = 10600,
                d = 1,
            },
            {
                t = 11000,
                d = 2,
            },
            {
                t = 11400,
                d = 0,
            },
            {
                t = 11800,
                d = 3,
            },
            {
                t = 12000,
                d = 0,
            },
            {
                t = 12200,
                d = 1,
            },
            {
                t = 12600,
                d = 3,
            },
            {
                t = 13400,
                d = 0,
            },
            {
                t = 13600,
                d = 3,
            },
            {
                t = 13800,
                d = 1,
            },
            {
                t = 14200,
                d = 2,
            },
            {
                t = 14600,
                d = 0,
            },
            {
                t = 15000,
                d = 3,
            },
            {
                t = 15200,
                d = 0,
            },
            {
                t = 15400,
                d = 1,
            },
            {
                t = 15800,
                d = 3,
            },
            {
                t = 16200,
                d = 4,
            },
            {
                t = 16400,
                d = 5,
            },
            {
                t = 16600,
                d = 7,
            },
            {
                t = 16800,
                d = 4,
            },
            {
                t = 17000,
                d = 7,
            },
            {
                t = 17200,
                d = 6,
            },
            {
                t = 17800,
                d = 5,
            },
            {
                t = 18000,
                d = 4,
            },
            {
                t = 18200,
                d = 7,
            },
            {
                t = 18400,
                d = 6,
            },
            {
                t = 18600,
                d = 4,
            },
            {
                t = 18800,
                d = 5,
            },
            {
                t = 19400,
                d = 7,
            },
            {
                t = 19600,
                d = 6,
            },
            {
                t = 19800,
                d = 4,
            },
            {
                t = 20000,
                d = 7,
            },
            {
                t = 20200,
                d = 4,
            },
            {
                t = 20400,
                d = 5,
            },
            {
                t = 21000,
                d = 5,
            },
            {
                t = 21200,
                d = 7,
            },
            {
                t = 21400,
                d = 4,
            },
            {
                t = 21600,
                d = 5,
            },
            {
                t = 21800,
                d = 4,
            },
            {
                t = 22000,
                d = 7,
            },
            {
                t = 22600,
                d = 0,
            },
            {
                t = 22800,
                d = 1,
            },
            {
                t = 23000,
                d = 3,
            },
            {
                t = 23200,
                d = 1,
            },
            {
                t = 23400,
                d = 2,
            },
            {
                t = 23600,
                d = 3,
            },
            {
                t = 24200,
                d = 2,
            },
            {
                t = 24400,
                d = 3,
            },
            {
                t = 24600,
                d = 1,
            },
            {
                t = 24800,
                d = 0,
            },
            {
                t = 25000,
                d = 3,
            },
            {
                t = 25200,
                d = 1,
            },
            {
                t = 25800,
                d = 0,
            },
            {
                t = 26000,
                d = 1,
            },
            {
                t = 26200,
                d = 3,
            },
            {
                t = 26400,
                d = 1,
            },
            {
                t = 26600,
                d = 3,
            },
            {
                t = 26800,
                d = 2,
            },
            {
                t = 27200,
                d = 3,
            },
            {
                t = 27400,
                d = 0,
            },
            {
                t = 27600,
                d = 3,
            },
            {
                t = 27800,
                d = 2,
            },
            {
                t = 28000,
                d = 0,
            },
            {
                t = 28200,
                d = 3,
            },
            {
                t = 28400,
                d = 0,
            },
            {
                t = 28800,
                d = 3,
                l = 250,
            },
            {
                t = 29000,
                d = 4,
            },
            {
                t = 29200,
                d = 5,
            },
            {
                t = 29400,
                d = 7,
            },
            {
                t = 29600,
                d = 4,
            },
            {
                t = 29800,
                d = 3,
            },
            {
                t = 29800,
                d = 5,
            },
            {
                t = 30000,
                d = 7,
            },
            {
                t = 30200,
                d = 1,
            },
            {
                t = 30200,
                d = 4,
            },
            {
                t = 30400,
                d = 6,
            },
            {
                t = 30600,
                d = 5,
            },
            {
                t = 30700,
                d = 4,
            },
            {
                t = 30800,
                d = 7,
            },
            {
                t = 31000,
                d = 6,
            },
            {
                t = 31200,
                d = 5,
                l = 300,
            },
            {
                t = 31400,
                d = 1,
            },
            {
                t = 31600,
                d = 3,
            },
            {
                t = 31600,
                d = 4,
            },
            {
                t = 31800,
                d = 1,
            },
            {
                t = 32000,
                d = 0,
            },
            {
                t = 32200,
                d = 6,
            },
            {
                t = 32400,
                d = 7,
            },
            {
                t = 32600,
                d = 6,
            },
            {
                t = 32800,
                d = 4,
            },
            {
                t = 33000,
                d = 1,
            },
            {
                t = 33000,
                d = 5,
            },
            {
                t = 33200,
                d = 7,
            },
            {
                t = 33400,
                d = 1,
            },
            {
                t = 33400,
                d = 4,
            },
            {
                t = 33600,
                d = 7,
            },
            {
                t = 33800,
                d = 5,
            },
            {
                t = 34000,
                d = 4,
            },
            {
                t = 34200,
                d = 2,
            },
            {
                t = 34200,
                d = 5,
            },
            {
                t = 34400,
                d = 0,
            },
            {
                t = 34400,
                d = 7,
                l = 350,
            },
            {
                t = 34600,
                d = 1,
            },
            {
                t = 34800,
                d = 3,
            },
            {
                t = 34800,
                d = 4,
            },
            {
                t = 35800,
                d = 3,
            },
            {
                t = 36000,
                d = 0,
            },
            {
                t = 36200,
                d = 3,
            },
            {
                t = 36400,
                d = 1,
            },
            {
                t = 37000,
                d = 3,
            },
            {
                t = 37200,
                d = 0,
            },
            {
                t = 37400,
                d = 3,
            },
            {
                t = 37600,
                d = 1,
            },
            {
                t = 37800,
                d = 0,
            },
            {
                t = 38000,
                d = 3,
            },
            {
                t = 38400,
                d = 1,
            },
            {
                t = 38600,
                d = 0,
            },
            {
                t = 39000,
                d = 3,
            },
            {
                t = 39200,
                d = 0,
            },
            {
                t = 39400,
                d = 3,
            },
            {
                t = 39600,
                d = 1,
            },
            {
                t = 40200,
                d = 0,
            },
            {
                t = 40400,
                d = 3,
            },
            {
                t = 40600,
                d = 0,
            },
            {
                t = 40800,
                d = 1,
            },
            {
                t = 41000,
                d = 0,
            },
            {
                t = 41200,
                d = 3,
            },
            {
                t = 41400,
                d = 1,
            },
            {
                t = 41600,
                d = 3,
            },
            {
                t = 41800,
                d = 5,
            },
            {
                t = 42000,
                d = 4,
            },
            {
                t = 42200,
                d = 7,
            },
            {
                t = 42400,
                d = 6,
            },
            {
                t = 42600,
                d = 0,
            },
            {
                t = 42600,
                d = 4,
            },
            {
                t = 42800,
                d = 7,
            },
            {
                t = 43000,
                d = 3,
            },
            {
                t = 43400,
                d = 5,
            },
            {
                t = 43600,
                d = 7,
            },
            {
                t = 43800,
                d = 1,
            },
            {
                t = 43800,
                d = 6,
            },
            {
                t = 44000,
                d = 3,
            },
            {
                t = 44000,
                d = 4,
            },
            {
                t = 44200,
                d = 0,
            },
            {
                t = 44200,
                d = 7,
            },
            {
                t = 44400,
                d = 2,
                k = "censor",
            },
            {
                t = 44400,
                d = 4,
            },
            {
                t = 44600,
                d = 3,
            },
            {
                t = 44800,
                d = 0,
            },
            {
                t = 45000,
                d = 5,
            },
            {
                t = 45200,
                d = 7,
            },
            {
                t = 45400,
                d = 6,
            },
            {
                t = 45600,
                d = 4,
            },
            {
                t = 45800,
                d = 3,
            },
            {
                t = 45900,
                d = 7,
            },
            {
                t = 46000,
                d = 4,
            },
            {
                t = 46200,
                d = 1,
            },
            {
                t = 46600,
                d = 2,
            },
            {
                t = 46600,
                d = 5,
            },
            {
                t = 46800,
                d = 1,
            },
            {
                t = 46800,
                d = 7,
            },
            {
                t = 47000,
                d = 3,
            },
            {
                t = 47000,
                d = 4,
            },
            {
                t = 47200,
                d = 1,
            },
            {
                t = 47200,
                d = 6,
            },
            {
                t = 47400,
                d = 0,
            },
            {
                t = 47400,
                d = 5,
            },
            {
                t = 47600,
                d = 3,
                l = 350,
            },
            {
                t = 47600,
                d = 6,
            },
            {
                t = 48200,
                d = 1,
            },
            {
                t = 48400,
                d = 0,
            },
            {
                t = 48600,
                d = 3,
            },
            {
                t = 48800,
                d = 2,
            },
            {
                t = 49000,
                d = 1,
            },
            {
                t = 49200,
                d = 3,
            },
            {
                t = 49400,
                d = 0,
            },
            {
                t = 49800,
                d = 3,
            },
            {
                t = 49900,
                d = 1,
            },
            {
                t = 50200,
                d = 2,
            },
            {
                t = 50400,
                d = 0,
            },
            {
                t = 50600,
                d = 3,
            },
            {
                t = 50800,
                d = 2,
                k = "censor",
            },
            {
                t = 51000,
                d = 3,
            },
            {
                t = 51200,
                d = 0,
            },
            {
                t = 51800,
                d = 0,
            },
            {
                t = 52000,
                d = 1,
            },
            {
                t = 52200,
                d = 2,
            },
            {
                t = 52400,
                d = 1,
            },
            {
                t = 52600,
                d = 0,
            },
            {
                t = 52800,
                d = 2,
            },
            {
                t = 53400,
                d = 1,
            },
            {
                t = 53600,
                d = 0,
            },
            {
                t = 53800,
                d = 3,
            },
            {
                t = 54000,
                d = 0,
            },
            {
                t = 54200,
                d = 3,
            },
            {
                t = 54400,
                d = 0,
            },
            {
                t = 54600,
                d = 4,
            },
            {
                t = 54800,
                d = 5,
            },
            {
                t = 55000,
                d = 7,
            },
            {
                t = 55200,
                d = 4,
            },
            {
                t = 55400,
                d = 1,
            },
            {
                t = 55400,
                d = 7,
            },
            {
                t = 55600,
                d = 5,
            },
            {
                t = 55800,
                d = 3,
            },
            {
                t = 56200,
                d = 6,
            },
            {
                t = 56400,
                d = 7,
            },
            {
                t = 56600,
                d = 1,
            },
            {
                t = 56600,
                d = 4,
            },
            {
                t = 56800,
                d = 3,
            },
            {
                t = 56800,
                d = 7,
            },
            {
                t = 57000,
                d = 2,
            },
            {
                t = 57000,
                d = 5,
            },
            {
                t = 57200,
                d = 0,
                k = "censor",
            },
            {
                t = 57200,
                d = 6,
            },
            {
                t = 57400,
                d = 3,
            },
            {
                t = 57600,
                d = 1,
            },
            {
                t = 57800,
                d = 5,
            },
            {
                t = 58000,
                d = 0,
            },
            {
                t = 58000,
                d = 4,
            },
            {
                t = 58200,
                d = 3,
            },
            {
                t = 58200,
                d = 6,
            },
            {
                t = 58400,
                d = 2,
            },
            {
                t = 58400,
                d = 7,
            },
            {
                t = 58600,
                d = 1,
            },
            {
                t = 58600,
                d = 6,
            },
            {
                t = 58800,
                d = 5,
            },
            {
                t = 59000,
                d = 3,
            },
            {
                t = 59400,
                d = 0,
            },
            {
                t = 59400,
                d = 6,
            },
            {
                t = 59600,
                d = 1,
            },
            {
                t = 59600,
                d = 7,
            },
            {
                t = 59800,
                d = 3,
            },
            {
                t = 59800,
                d = 4,
            },
            {
                t = 60000,
                d = 1,
            },
            {
                t = 60000,
                d = 6,
            },
            {
                t = 60200,
                d = 2,
            },
            {
                t = 60200,
                d = 7,
            },
            {
                t = 60400,
                d = 0,
                l = 300,
            },
            {
                t = 60400,
                d = 4,
            },
            {
                t = 60800,
                d = 3,
            },
            {
                t = 61200,
                d = 1,
            },
            {
                t = 61400,
                d = 0,
            },
            {
                t = 61600,
                d = 2,
            },
            {
                t = 61800,
                d = 3,
            },
            {
                t = 62200,
                d = 0,
            },
            {
                t = 63000,
                d = 2,
            },
            {
                t = 63200,
                d = 3,
            },
            {
                t = 63400,
                d = 1,
            },
            {
                t = 63600,
                d = 3,
                k = "censor",
            },
            {
                t = 63800,
                d = 0,
            },
            {
                t = 64000,
                d = 1,
            },
            {
                t = 64200,
                d = 0,
            },
            {
                t = 64400,
                d = 2,
            },
            {
                t = 64600,
                d = 1,
            },
            {
                t = 65000,
                d = 2,
            },
            {
                t = 65400,
                d = 0,
            },
            {
                t = 65800,
                d = 1,
            },
            {
                t = 67200,
                d = 1,
            },
            {
                t = 67400,
                d = 7,
            },
            {
                t = 67600,
                d = 5,
            },
            {
                t = 67800,
                d = 0,
            },
            {
                t = 67800,
                d = 4,
            },
            {
                t = 68000,
                d = 3,
            },
            {
                t = 68000,
                d = 7,
            },
            {
                t = 68200,
                d = 0,
            },
            {
                t = 68200,
                d = 5,
            },
            {
                t = 68400,
                d = 1,
            },
            {
                t = 68400,
                d = 7,
            },
            {
                t = 68600,
                d = 3,
            },
            {
                t = 68600,
                d = 4,
            },
            {
                t = 68800,
                d = 6,
            },
            {
                t = 69000,
                d = 5,
            },
            {
                t = 69200,
                d = 7,
            },
            {
                t = 69400,
                d = 1,
            },
            {
                t = 69400,
                d = 5,
            },
            {
                t = 69600,
                d = 0,
            },
            {
                t = 69600,
                d = 4,
                l = 350,
            },
            {
                t = 69800,
                d = 3,
            },
            {
                t = 70000,
                d = 1,
            },
            {
                t = 70000,
                d = 7,
            },
            {
                t = 70200,
                d = 3,
            },
            {
                t = 70400,
                d = 1,
            },
            {
                t = 70600,
                d = 6,
            },
            {
                t = 70800,
                d = 5,
            },
            {
                t = 71000,
                d = 2,
            },
            {
                t = 71000,
                d = 7,
            },
            {
                t = 71200,
                d = 1,
            },
            {
                t = 71200,
                d = 5,
            },
            {
                t = 71400,
                d = 3,
            },
            {
                t = 71400,
                d = 4,
            },
            {
                t = 71600,
                d = 0,
            },
            {
                t = 71600,
                d = 7,
            },
            {
                t = 71800,
                d = 3,
            },
            {
                t = 71800,
                d = 6,
            },
            {
                t = 72000,
                d = 4,
            },
            {
                t = 72200,
                d = 5,
            },
            {
                t = 72400,
                d = 6,
            },
            {
                t = 72600,
                d = 4,
            },
            {
                t = 72800,
                d = 5,
                l = 350,
            },
            {
                t = 73000,
                d = 1,
            },
            {
                t = 73200,
                d = 0,
            },
            {
                t = 73200,
                d = 7,
            },
            {
                t = 73400,
                d = 2,
            },
            {
                t = 73600,
                d = 0,
            },
            {
                t = 73800,
                d = 1,
            },
            {
                t = 74000,
                d = 3,
            },
            {
                t = 74200,
                d = 2,
            },
            {
                t = 74400,
                d = 0,
            },
            {
                t = 74600,
                d = 1,
            },
            {
                t = 74800,
                d = 0,
            },
            {
                t = 75400,
                d = 3,
            },
            {
                t = 75600,
                d = 1,
            },
            {
                t = 75800,
                d = 2,
            },
            {
                t = 76000,
                d = 0,
            },
            {
                t = 76200,
                d = 3,
            },
            {
                t = 76400,
                d = 2,
            },
            {
                t = 77000,
                d = 1,
            },
            {
                t = 77200,
                d = 0,
            },
            {
                t = 77400,
                d = 3,
            },
            {
                t = 77600,
                d = 2,
            },
            {
                t = 77800,
                d = 3,
            },
            {
                t = 78000,
                d = 0,
            },
            {
                t = 78400,
                d = 3,
            },
            {
                t = 78600,
                d = 2,
            },
            {
                t = 78800,
                d = 0,
            },
            {
                t = 79000,
                d = 1,
            },
            {
                t = 79200,
                d = 3,
            },
            {
                t = 79400,
                d = 0,
            },
            {
                t = 79600,
                d = 2,
            },
        },
        normal = {
            {
                t = 3800,
                d = 7,
            },
            {
                t = 4000,
                d = 5,
            },
            {
                t = 4200,
                d = 4,
            },
            {
                t = 4600,
                d = 7,
            },
            {
                t = 5000,
                d = 4,
            },
            {
                t = 5400,
                d = 6,
            },
            {
                t = 5600,
                d = 5,
            },
            {
                t = 5800,
                d = 7,
            },
            {
                t = 6200,
                d = 5,
            },
            {
                t = 7000,
                d = 7,
            },
            {
                t = 7200,
                d = 5,
            },
            {
                t = 7400,
                d = 4,
            },
            {
                t = 7800,
                d = 7,
            },
            {
                t = 8200,
                d = 6,
            },
            {
                t = 8600,
                d = 4,
            },
            {
                t = 8800,
                d = 5,
            },
            {
                t = 9000,
                d = 7,
            },
            {
                t = 9400,
                d = 5,
            },
            {
                t = 10200,
                d = 0,
            },
            {
                t = 10400,
                d = 3,
            },
            {
                t = 10600,
                d = 1,
            },
            {
                t = 11000,
                d = 2,
            },
            {
                t = 11400,
                d = 0,
            },
            {
                t = 11800,
                d = 3,
            },
            {
                t = 12000,
                d = 0,
            },
            {
                t = 12200,
                d = 1,
            },
            {
                t = 12600,
                d = 3,
            },
            {
                t = 13400,
                d = 0,
            },
            {
                t = 13600,
                d = 3,
            },
            {
                t = 13800,
                d = 1,
            },
            {
                t = 14200,
                d = 2,
            },
            {
                t = 14600,
                d = 0,
            },
            {
                t = 15000,
                d = 3,
            },
            {
                t = 15200,
                d = 0,
            },
            {
                t = 15400,
                d = 1,
            },
            {
                t = 15800,
                d = 3,
            },
            {
                t = 16200,
                d = 4,
            },
            {
                t = 16400,
                d = 5,
            },
            {
                t = 16600,
                d = 7,
            },
            {
                t = 16800,
                d = 4,
            },
            {
                t = 17000,
                d = 7,
            },
            {
                t = 17200,
                d = 6,
            },
            {
                t = 17800,
                d = 5,
            },
            {
                t = 18000,
                d = 4,
            },
            {
                t = 18200,
                d = 7,
            },
            {
                t = 18400,
                d = 6,
            },
            {
                t = 18600,
                d = 4,
            },
            {
                t = 18800,
                d = 5,
            },
            {
                t = 19400,
                d = 7,
            },
            {
                t = 19600,
                d = 6,
            },
            {
                t = 19800,
                d = 4,
            },
            {
                t = 20000,
                d = 7,
            },
            {
                t = 20200,
                d = 4,
            },
            {
                t = 20400,
                d = 5,
            },
            {
                t = 21000,
                d = 5,
            },
            {
                t = 21200,
                d = 7,
            },
            {
                t = 21400,
                d = 4,
            },
            {
                t = 21600,
                d = 5,
            },
            {
                t = 21800,
                d = 4,
            },
            {
                t = 22000,
                d = 7,
            },
            {
                t = 22600,
                d = 0,
            },
            {
                t = 22800,
                d = 1,
            },
            {
                t = 23000,
                d = 3,
            },
            {
                t = 23200,
                d = 1,
            },
            {
                t = 23400,
                d = 2,
            },
            {
                t = 23600,
                d = 3,
            },
            {
                t = 24200,
                d = 2,
            },
            {
                t = 24400,
                d = 3,
            },
            {
                t = 24600,
                d = 1,
            },
            {
                t = 24800,
                d = 0,
            },
            {
                t = 25000,
                d = 3,
            },
            {
                t = 25200,
                d = 1,
            },
            {
                t = 25800,
                d = 0,
            },
            {
                t = 26000,
                d = 1,
            },
            {
                t = 26200,
                d = 3,
            },
            {
                t = 26400,
                d = 1,
            },
            {
                t = 26600,
                d = 3,
            },
            {
                t = 26800,
                d = 2,
            },
            {
                t = 27200,
                d = 3,
            },
            {
                t = 27400,
                d = 0,
            },
            {
                t = 27600,
                d = 3,
            },
            {
                t = 27800,
                d = 2,
            },
            {
                t = 28000,
                d = 0,
            },
            {
                t = 28200,
                d = 3,
            },
            {
                t = 28400,
                d = 0,
            },
            {
                t = 28800,
                d = 3,
                l = 250,
            },
            {
                t = 29000,
                d = 4,
            },
            {
                t = 29200,
                d = 5,
            },
            {
                t = 29400,
                d = 7,
            },
            {
                t = 29600,
                d = 4,
            },
            {
                t = 29800,
                d = 3,
            },
            {
                t = 29800,
                d = 5,
            },
            {
                t = 30000,
                d = 7,
            },
            {
                t = 30200,
                d = 1,
            },
            {
                t = 30200,
                d = 4,
            },
            {
                t = 30400,
                d = 6,
            },
            {
                t = 30600,
                d = 5,
            },
            {
                t = 30700,
                d = 4,
            },
            {
                t = 30800,
                d = 7,
            },
            {
                t = 31000,
                d = 6,
            },
            {
                t = 31200,
                d = 5,
                l = 300,
            },
            {
                t = 31400,
                d = 1,
            },
            {
                t = 31600,
                d = 3,
            },
            {
                t = 31600,
                d = 4,
            },
            {
                t = 31800,
                d = 1,
            },
            {
                t = 32000,
                d = 0,
            },
            {
                t = 32200,
                d = 6,
            },
            {
                t = 32400,
                d = 7,
            },
            {
                t = 32600,
                d = 6,
            },
            {
                t = 32800,
                d = 4,
            },
            {
                t = 33000,
                d = 1,
            },
            {
                t = 33000,
                d = 5,
            },
            {
                t = 33200,
                d = 7,
            },
            {
                t = 33400,
                d = 1,
            },
            {
                t = 33400,
                d = 4,
            },
            {
                t = 33600,
                d = 7,
            },
            {
                t = 33800,
                d = 5,
            },
            {
                t = 34000,
                d = 4,
            },
            {
                t = 34200,
                d = 2,
            },
            {
                t = 34200,
                d = 5,
            },
            {
                t = 34300,
                d = 3,
            },
            {
                t = 34400,
                d = 0,
            },
            {
                t = 34400,
                d = 7,
                l = 350,
            },
            {
                t = 34600,
                d = 1,
            },
            {
                t = 34800,
                d = 3,
            },
            {
                t = 34800,
                d = 4,
            },
            {
                t = 35800,
                d = 3,
            },
            {
                t = 35900,
                d = 2,
            },
            {
                t = 36000,
                d = 0,
            },
            {
                t = 36200,
                d = 3,
            },
            {
                t = 36400,
                d = 1,
            },
            {
                t = 37000,
                d = 3,
            },
            {
                t = 37100,
                d = 2,
            },
            {
                t = 37200,
                d = 0,
            },
            {
                t = 37400,
                d = 3,
            },
            {
                t = 37600,
                d = 1,
            },
            {
                t = 37800,
                d = 0,
            },
            {
                t = 38000,
                d = 3,
            },
            {
                t = 38400,
                d = 1,
            },
            {
                t = 38600,
                d = 0,
            },
            {
                t = 39000,
                d = 3,
            },
            {
                t = 39100,
                d = 2,
            },
            {
                t = 39200,
                d = 0,
            },
            {
                t = 39400,
                d = 3,
            },
            {
                t = 39600,
                d = 1,
            },
            {
                t = 40200,
                d = 0,
            },
            {
                t = 40300,
                d = 2,
            },
            {
                t = 40400,
                d = 3,
            },
            {
                t = 40600,
                d = 0,
            },
            {
                t = 40800,
                d = 1,
            },
            {
                t = 41000,
                d = 0,
            },
            {
                t = 41200,
                d = 3,
            },
            {
                t = 41400,
                d = 1,
            },
            {
                t = 41600,
                d = 3,
            },
            {
                t = 41800,
                d = 5,
            },
            {
                t = 42000,
                d = 4,
            },
            {
                t = 42200,
                d = 7,
            },
            {
                t = 42400,
                d = 6,
            },
            {
                t = 42600,
                d = 0,
            },
            {
                t = 42600,
                d = 4,
            },
            {
                t = 42700,
                d = 5,
            },
            {
                t = 42800,
                d = 7,
            },
            {
                t = 43000,
                d = 3,
            },
            {
                t = 43400,
                d = 5,
            },
            {
                t = 43600,
                d = 7,
            },
            {
                t = 43800,
                d = 1,
            },
            {
                t = 43800,
                d = 6,
            },
            {
                t = 44000,
                d = 3,
            },
            {
                t = 44000,
                d = 4,
            },
            {
                t = 44200,
                d = 0,
            },
            {
                t = 44200,
                d = 7,
            },
            {
                t = 44300,
                d = 6,
            },
            {
                t = 44400,
                d = 2,
                k = "censor",
            },
            {
                t = 44400,
                d = 4,
            },
            {
                t = 44600,
                d = 3,
            },
            {
                t = 44800,
                d = 0,
            },
            {
                t = 45000,
                d = 5,
            },
            {
                t = 45200,
                d = 7,
            },
            {
                t = 45400,
                d = 6,
            },
            {
                t = 45600,
                d = 4,
            },
            {
                t = 45800,
                d = 3,
            },
            {
                t = 45800,
                d = 5,
            },
            {
                t = 45900,
                d = 7,
            },
            {
                t = 46000,
                d = 4,
            },
            {
                t = 46200,
                d = 1,
            },
            {
                t = 46600,
                d = 2,
            },
            {
                t = 46600,
                d = 5,
            },
            {
                t = 46800,
                d = 1,
            },
            {
                t = 46800,
                d = 7,
            },
            {
                t = 47000,
                d = 3,
            },
            {
                t = 47000,
                d = 4,
            },
            {
                t = 47200,
                d = 1,
            },
            {
                t = 47200,
                d = 6,
            },
            {
                t = 47400,
                d = 0,
            },
            {
                t = 47400,
                d = 7,
            },
            {
                t = 47500,
                d = 5,
            },
            {
                t = 47600,
                d = 3,
                l = 350,
            },
            {
                t = 47600,
                d = 6,
            },
            {
                t = 48200,
                d = 1,
            },
            {
                t = 48400,
                d = 0,
            },
            {
                t = 48600,
                d = 3,
            },
            {
                t = 48700,
                d = 1,
            },
            {
                t = 48800,
                d = 2,
            },
            {
                t = 49000,
                d = 1,
            },
            {
                t = 49200,
                d = 3,
            },
            {
                t = 49400,
                d = 0,
            },
            {
                t = 49800,
                d = 3,
            },
            {
                t = 49900,
                d = 1,
            },
            {
                t = 50200,
                d = 2,
            },
            {
                t = 50400,
                d = 0,
            },
            {
                t = 50600,
                d = 3,
            },
            {
                t = 50800,
                d = 2,
                k = "censor",
            },
            {
                t = 51000,
                d = 3,
            },
            {
                t = 51200,
                d = 0,
            },
            {
                t = 51800,
                d = 0,
            },
            {
                t = 52000,
                d = 1,
            },
            {
                t = 52200,
                d = 2,
            },
            {
                t = 52300,
                d = 3,
            },
            {
                t = 52400,
                d = 1,
            },
            {
                t = 52600,
                d = 0,
            },
            {
                t = 52800,
                d = 2,
            },
            {
                t = 53400,
                d = 1,
            },
            {
                t = 53600,
                d = 0,
            },
            {
                t = 53800,
                d = 3,
            },
            {
                t = 53900,
                d = 2,
            },
            {
                t = 54000,
                d = 0,
            },
            {
                t = 54200,
                d = 3,
            },
            {
                t = 54400,
                d = 0,
            },
            {
                t = 54600,
                d = 4,
            },
            {
                t = 54800,
                d = 5,
            },
            {
                t = 55000,
                d = 7,
            },
            {
                t = 55200,
                d = 4,
            },
            {
                t = 55400,
                d = 1,
            },
            {
                t = 55400,
                d = 5,
            },
            {
                t = 55500,
                d = 7,
            },
            {
                t = 55600,
                d = 5,
            },
            {
                t = 55800,
                d = 3,
            },
            {
                t = 56200,
                d = 6,
            },
            {
                t = 56400,
                d = 7,
            },
            {
                t = 56600,
                d = 1,
            },
            {
                t = 56600,
                d = 4,
            },
            {
                t = 56800,
                d = 3,
            },
            {
                t = 56800,
                d = 7,
            },
            {
                t = 57000,
                d = 2,
            },
            {
                t = 57000,
                d = 5,
            },
            {
                t = 57100,
                d = 4,
            },
            {
                t = 57200,
                d = 0,
                k = "censor",
            },
            {
                t = 57200,
                d = 6,
            },
            {
                t = 57400,
                d = 3,
            },
            {
                t = 57600,
                d = 1,
            },
            {
                t = 57800,
                d = 5,
            },
            {
                t = 58000,
                d = 0,
            },
            {
                t = 58000,
                d = 4,
            },
            {
                t = 58200,
                d = 3,
            },
            {
                t = 58200,
                d = 6,
            },
            {
                t = 58400,
                d = 2,
            },
            {
                t = 58400,
                d = 7,
            },
            {
                t = 58600,
                d = 1,
            },
            {
                t = 58600,
                d = 6,
            },
            {
                t = 58700,
                d = 4,
            },
            {
                t = 58800,
                d = 5,
            },
            {
                t = 59000,
                d = 3,
            },
            {
                t = 59400,
                d = 0,
            },
            {
                t = 59400,
                d = 6,
            },
            {
                t = 59600,
                d = 1,
            },
            {
                t = 59600,
                d = 7,
            },
            {
                t = 59800,
                d = 3,
            },
            {
                t = 59800,
                d = 4,
            },
            {
                t = 60000,
                d = 1,
            },
            {
                t = 60000,
                d = 6,
            },
            {
                t = 60200,
                d = 2,
            },
            {
                t = 60200,
                d = 7,
            },
            {
                t = 60300,
                d = 6,
            },
            {
                t = 60400,
                d = 0,
                l = 300,
            },
            {
                t = 60400,
                d = 4,
            },
            {
                t = 60800,
                d = 3,
            },
            {
                t = 61200,
                d = 1,
            },
            {
                t = 61400,
                d = 0,
            },
            {
                t = 61600,
                d = 2,
            },
            {
                t = 61800,
                d = 3,
            },
            {
                t = 62200,
                d = 0,
            },
            {
                t = 63000,
                d = 2,
            },
            {
                t = 63200,
                d = 3,
            },
            {
                t = 63400,
                d = 1,
            },
            {
                t = 63600,
                d = 3,
                k = "censor",
            },
            {
                t = 63800,
                d = 0,
            },
            {
                t = 64000,
                d = 1,
            },
            {
                t = 64200,
                d = 0,
            },
            {
                t = 64400,
                d = 2,
            },
            {
                t = 64600,
                d = 1,
            },
            {
                t = 65000,
                d = 2,
            },
            {
                t = 65400,
                d = 0,
            },
            {
                t = 65800,
                d = 1,
            },
            {
                t = 67200,
                d = 1,
            },
            {
                t = 67400,
                d = 7,
            },
            {
                t = 67600,
                d = 5,
            },
            {
                t = 67800,
                d = 0,
            },
            {
                t = 67800,
                d = 4,
            },
            {
                t = 68000,
                d = 3,
            },
            {
                t = 68000,
                d = 7,
            },
            {
                t = 68200,
                d = 0,
            },
            {
                t = 68200,
                d = 5,
            },
            {
                t = 68400,
                d = 1,
            },
            {
                t = 68400,
                d = 7,
            },
            {
                t = 68600,
                d = 3,
            },
            {
                t = 68600,
                d = 4,
            },
            {
                t = 68800,
                d = 6,
            },
            {
                t = 69000,
                d = 5,
            },
            {
                t = 69100,
                d = 4,
            },
            {
                t = 69200,
                d = 7,
            },
            {
                t = 69400,
                d = 1,
            },
            {
                t = 69400,
                d = 5,
            },
            {
                t = 69600,
                d = 0,
            },
            {
                t = 69600,
                d = 4,
                l = 350,
            },
            {
                t = 69800,
                d = 3,
            },
            {
                t = 69900,
                d = 2,
            },
            {
                t = 70000,
                d = 1,
            },
            {
                t = 70000,
                d = 7,
            },
            {
                t = 70200,
                d = 3,
            },
            {
                t = 70400,
                d = 1,
            },
            {
                t = 70600,
                d = 6,
            },
            {
                t = 70800,
                d = 5,
            },
            {
                t = 71000,
                d = 2,
            },
            {
                t = 71000,
                d = 7,
            },
            {
                t = 71200,
                d = 1,
            },
            {
                t = 71200,
                d = 5,
            },
            {
                t = 71400,
                d = 3,
            },
            {
                t = 71400,
                d = 4,
            },
            {
                t = 71600,
                d = 0,
            },
            {
                t = 71600,
                d = 7,
            },
            {
                t = 71800,
                d = 3,
            },
            {
                t = 71800,
                d = 6,
            },
            {
                t = 72000,
                d = 4,
            },
            {
                t = 72200,
                d = 5,
            },
            {
                t = 72400,
                d = 6,
            },
            {
                t = 72600,
                d = 4,
            },
            {
                t = 72800,
                d = 5,
                l = 350,
            },
            {
                t = 73000,
                d = 1,
            },
            {
                t = 73200,
                d = 0,
            },
            {
                t = 73200,
                d = 7,
            },
            {
                t = 73400,
                d = 2,
            },
            {
                t = 73500,
                d = 3,
            },
            {
                t = 73600,
                d = 0,
            },
            {
                t = 73800,
                d = 1,
            },
            {
                t = 73900,
                d = 3,
            },
            {
                t = 74000,
                d = 1,
            },
            {
                t = 74200,
                d = 2,
            },
            {
                t = 74400,
                d = 0,
            },
            {
                t = 74600,
                d = 1,
            },
            {
                t = 74800,
                d = 0,
            },
            {
                t = 75400,
                d = 3,
            },
            {
                t = 75600,
                d = 1,
            },
            {
                t = 75800,
                d = 2,
            },
            {
                t = 76000,
                d = 0,
            },
            {
                t = 76200,
                d = 3,
            },
            {
                t = 76400,
                d = 2,
            },
            {
                t = 77000,
                d = 1,
            },
            {
                t = 77200,
                d = 0,
            },
            {
                t = 77400,
                d = 3,
            },
            {
                t = 77600,
                d = 2,
            },
            {
                t = 77800,
                d = 3,
            },
            {
                t = 78000,
                d = 0,
            },
            {
                t = 78400,
                d = 3,
            },
            {
                t = 78600,
                d = 2,
            },
            {
                t = 78800,
                d = 0,
            },
            {
                t = 79000,
                d = 1,
            },
            {
                t = 79200,
                d = 3,
            },
            {
                t = 79400,
                d = 0,
            },
            {
                t = 79600,
                d = 2,
            },
        },
        hard = {
            {
                t = 3800,
                d = 7,
            },
            {
                t = 4000,
                d = 5,
            },
            {
                t = 4200,
                d = 4,
            },
            {
                t = 4600,
                d = 7,
            },
            {
                t = 5000,
                d = 4,
            },
            {
                t = 5400,
                d = 6,
            },
            {
                t = 5600,
                d = 5,
            },
            {
                t = 5800,
                d = 7,
            },
            {
                t = 6200,
                d = 5,
            },
            {
                t = 7000,
                d = 7,
            },
            {
                t = 7200,
                d = 5,
            },
            {
                t = 7400,
                d = 4,
            },
            {
                t = 7800,
                d = 7,
            },
            {
                t = 8200,
                d = 6,
            },
            {
                t = 8600,
                d = 4,
            },
            {
                t = 8800,
                d = 5,
            },
            {
                t = 9000,
                d = 7,
            },
            {
                t = 9400,
                d = 5,
            },
            {
                t = 10200,
                d = 0,
            },
            {
                t = 10400,
                d = 3,
            },
            {
                t = 10400,
                d = 2,
            },
            {
                t = 10600,
                d = 1,
            },
            {
                t = 11000,
                d = 2,
            },
            {
                t = 11400,
                d = 0,
            },
            {
                t = 11800,
                d = 3,
            },
            {
                t = 12000,
                d = 0,
            },
            {
                t = 12000,
                d = 2,
            },
            {
                t = 12200,
                d = 1,
            },
            {
                t = 12600,
                d = 3,
            },
            {
                t = 13400,
                d = 0,
            },
            {
                t = 13600,
                d = 3,
            },
            {
                t = 13600,
                d = 2,
            },
            {
                t = 13800,
                d = 1,
            },
            {
                t = 14200,
                d = 2,
            },
            {
                t = 14600,
                d = 0,
            },
            {
                t = 15000,
                d = 3,
            },
            {
                t = 15200,
                d = 0,
            },
            {
                t = 15200,
                d = 2,
            },
            {
                t = 15400,
                d = 1,
            },
            {
                t = 15800,
                d = 3,
            },
            {
                t = 16200,
                d = 4,
            },
            {
                t = 16400,
                d = 5,
            },
            {
                t = 16600,
                d = 7,
            },
            {
                t = 16800,
                d = 4,
            },
            {
                t = 17000,
                d = 7,
            },
            {
                t = 17200,
                d = 6,
            },
            {
                t = 17800,
                d = 5,
            },
            {
                t = 18000,
                d = 4,
            },
            {
                t = 18200,
                d = 7,
            },
            {
                t = 18400,
                d = 6,
            },
            {
                t = 18600,
                d = 4,
            },
            {
                t = 18800,
                d = 5,
            },
            {
                t = 19400,
                d = 7,
            },
            {
                t = 19600,
                d = 6,
            },
            {
                t = 19800,
                d = 4,
            },
            {
                t = 20000,
                d = 7,
            },
            {
                t = 20200,
                d = 4,
            },
            {
                t = 20400,
                d = 5,
            },
            {
                t = 21000,
                d = 5,
            },
            {
                t = 21200,
                d = 7,
            },
            {
                t = 21400,
                d = 4,
            },
            {
                t = 21600,
                d = 5,
            },
            {
                t = 21800,
                d = 4,
            },
            {
                t = 22000,
                d = 7,
            },
            {
                t = 22600,
                d = 0,
            },
            {
                t = 22800,
                d = 1,
            },
            {
                t = 23000,
                d = 3,
            },
            {
                t = 23200,
                d = 1,
            },
            {
                t = 23250,
                d = 0,
            },
            {
                t = 23400,
                d = 2,
            },
            {
                t = 23600,
                d = 3,
            },
            {
                t = 23600,
                d = 1,
            },
            {
                t = 24200,
                d = 2,
            },
            {
                t = 24400,
                d = 3,
            },
            {
                t = 24600,
                d = 1,
            },
            {
                t = 24800,
                d = 0,
            },
            {
                t = 24800,
                d = 2,
            },
            {
                t = 25000,
                d = 3,
            },
            {
                t = 25200,
                d = 0,
            },
            {
                t = 25200,
                d = 1,
            },
            {
                t = 25800,
                d = 0,
            },
            {
                t = 26000,
                d = 1,
            },
            {
                t = 26200,
                d = 3,
            },
            {
                t = 26400,
                d = 1,
            },
            {
                t = 26450,
                d = 0,
            },
            {
                t = 26600,
                d = 3,
            },
            {
                t = 26800,
                d = 1,
            },
            {
                t = 26800,
                d = 2,
            },
            {
                t = 27200,
                d = 3,
            },
            {
                t = 27400,
                d = 0,
            },
            {
                t = 27600,
                d = 1,
            },
            {
                t = 27600,
                d = 3,
            },
            {
                t = 27800,
                d = 2,
            },
            {
                t = 28000,
                d = 0,
            },
            {
                t = 28000,
                d = 1,
            },
            {
                t = 28200,
                d = 3,
            },
            {
                t = 28400,
                d = 0,
            },
            {
                t = 28800,
                d = 3,
                l = 250,
            },
            {
                t = 29000,
                d = 4,
            },
            {
                t = 29200,
                d = 5,
            },
            {
                t = 29400,
                d = 7,
            },
            {
                t = 29600,
                d = 4,
            },
            {
                t = 29800,
                d = 3,
            },
            {
                t = 29800,
                d = 5,
            },
            {
                t = 30000,
                d = 7,
            },
            {
                t = 30200,
                d = 1,
            },
            {
                t = 30200,
                d = 4,
            },
            {
                t = 30400,
                d = 6,
            },
            {
                t = 30600,
                d = 5,
            },
            {
                t = 30700,
                d = 4,
            },
            {
                t = 30800,
                d = 7,
            },
            {
                t = 31000,
                d = 6,
            },
            {
                t = 31200,
                d = 5,
                l = 300,
            },
            {
                t = 31400,
                d = 1,
            },
            {
                t = 31600,
                d = 3,
            },
            {
                t = 31600,
                d = 4,
            },
            {
                t = 31800,
                d = 1,
            },
            {
                t = 32000,
                d = 0,
            },
            {
                t = 32200,
                d = 6,
            },
            {
                t = 32400,
                d = 7,
            },
            {
                t = 32400,
                d = 5,
            },
            {
                t = 32600,
                d = 6,
            },
            {
                t = 32800,
                d = 4,
            },
            {
                t = 33000,
                d = 1,
            },
            {
                t = 33000,
                d = 5,
            },
            {
                t = 33200,
                d = 7,
            },
            {
                t = 33400,
                d = 1,
            },
            {
                t = 33400,
                d = 4,
            },
            {
                t = 33600,
                d = 7,
            },
            {
                t = 33800,
                d = 5,
            },
            {
                t = 34000,
                d = 4,
            },
            {
                t = 34000,
                d = 6,
            },
            {
                t = 34200,
                d = 2,
            },
            {
                t = 34200,
                d = 5,
            },
            {
                t = 34300,
                d = 3,
            },
            {
                t = 34400,
                d = 0,
            },
            {
                t = 34400,
                d = 7,
                l = 350,
            },
            {
                t = 34600,
                d = 1,
            },
            {
                t = 34800,
                d = 3,
            },
            {
                t = 34800,
                d = 4,
            },
            {
                t = 35800,
                d = 3,
            },
            {
                t = 35900,
                d = 2,
            },
            {
                t = 36000,
                d = 0,
            },
            {
                t = 36000,
                d = 1,
            },
            {
                t = 36200,
                d = 3,
            },
            {
                t = 36400,
                d = 1,
            },
            {
                t = 37000,
                d = 3,
            },
            {
                t = 37100,
                d = 2,
            },
            {
                t = 37200,
                d = 0,
            },
            {
                t = 37400,
                d = 3,
            },
            {
                t = 37400,
                d = 2,
            },
            {
                t = 37600,
                d = 1,
            },
            {
                t = 37800,
                d = 2,
            },
            {
                t = 37800,
                d = 0,
            },
            {
                t = 38000,
                d = 3,
            },
            {
                t = 38400,
                d = 1,
            },
            {
                t = 38600,
                d = 0,
            },
            {
                t = 39000,
                d = 3,
            },
            {
                t = 39100,
                d = 2,
            },
            {
                t = 39200,
                d = 0,
            },
            {
                t = 39400,
                d = 3,
            },
            {
                t = 39600,
                d = 1,
            },
            {
                t = 39600,
                d = 0,
            },
            {
                t = 40200,
                d = 0,
            },
            {
                t = 40300,
                d = 2,
            },
            {
                t = 40400,
                d = 3,
            },
            {
                t = 40400,
                d = 1,
            },
            {
                t = 40600,
                d = 0,
            },
            {
                t = 40800,
                d = 1,
            },
            {
                t = 41000,
                d = 0,
            },
            {
                t = 41200,
                d = 3,
            },
            {
                t = 41200,
                d = 2,
            },
            {
                t = 41400,
                d = 1,
            },
            {
                t = 41600,
                d = 3,
            },
            {
                t = 41800,
                d = 5,
            },
            {
                t = 42000,
                d = 4,
            },
            {
                t = 42200,
                d = 7,
            },
            {
                t = 42400,
                d = 6,
            },
            {
                t = 42600,
                d = 0,
            },
            {
                t = 42600,
                d = 4,
            },
            {
                t = 42700,
                d = 5,
            },
            {
                t = 42800,
                d = 7,
            },
            {
                t = 42800,
                d = 6,
            },
            {
                t = 43000,
                d = 3,
            },
            {
                t = 43400,
                d = 5,
            },
            {
                t = 43600,
                d = 7,
            },
            {
                t = 43800,
                d = 1,
            },
            {
                t = 43800,
                d = 6,
            },
            {
                t = 44000,
                d = 3,
            },
            {
                t = 44000,
                d = 4,
            },
            {
                t = 44200,
                d = 0,
            },
            {
                t = 44200,
                d = 7,
            },
            {
                t = 44300,
                d = 6,
            },
            {
                t = 44400,
                d = 2,
                k = "censor",
            },
            {
                t = 44400,
                d = 1,
                k = "censor",
            },
            {
                t = 44400,
                d = 5,
            },
            {
                t = 44400,
                d = 4,
            },
            {
                t = 44600,
                d = 3,
            },
            {
                t = 44800,
                d = 0,
            },
            {
                t = 45000,
                d = 5,
            },
            {
                t = 45200,
                d = 7,
            },
            {
                t = 45400,
                d = 6,
            },
            {
                t = 45600,
                d = 4,
            },
            {
                t = 45800,
                d = 3,
            },
            {
                t = 45800,
                d = 5,
            },
            {
                t = 45900,
                d = 7,
            },
            {
                t = 46000,
                d = 6,
            },
            {
                t = 46000,
                d = 4,
            },
            {
                t = 46200,
                d = 1,
            },
            {
                t = 46600,
                d = 2,
            },
            {
                t = 46600,
                d = 5,
            },
            {
                t = 46800,
                d = 1,
            },
            {
                t = 46800,
                d = 7,
            },
            {
                t = 47000,
                d = 3,
            },
            {
                t = 47000,
                d = 4,
            },
            {
                t = 47200,
                d = 1,
            },
            {
                t = 47200,
                d = 6,
            },
            {
                t = 47400,
                d = 0,
            },
            {
                t = 47400,
                d = 7,
            },
            {
                t = 47500,
                d = 5,
            },
            {
                t = 47600,
                d = 3,
                l = 350,
            },
            {
                t = 47600,
                d = 4,
            },
            {
                t = 47600,
                d = 6,
            },
            {
                t = 48200,
                d = 1,
            },
            {
                t = 48400,
                d = 0,
            },
            {
                t = 48600,
                d = 3,
            },
            {
                t = 48700,
                d = 1,
            },
            {
                t = 48800,
                d = 0,
            },
            {
                t = 48800,
                d = 2,
            },
            {
                t = 49000,
                d = 1,
            },
            {
                t = 49200,
                d = 3,
            },
            {
                t = 49400,
                d = 0,
            },
            {
                t = 49800,
                d = 3,
            },
            {
                t = 49900,
                d = 1,
            },
            {
                t = 50200,
                d = 2,
            },
            {
                t = 50400,
                d = 0,
            },
            {
                t = 50400,
                d = 1,
            },
            {
                t = 50600,
                d = 3,
            },
            {
                t = 50800,
                d = 2,
                k = "censor",
            },
            {
                t = 50800,
                d = 1,
                k = "censor",
            },
            {
                t = 51000,
                d = 3,
            },
            {
                t = 51200,
                d = 0,
            },
            {
                t = 51800,
                d = 0,
            },
            {
                t = 52000,
                d = 1,
            },
            {
                t = 52200,
                d = 2,
            },
            {
                t = 52300,
                d = 3,
            },
            {
                t = 52400,
                d = 1,
            },
            {
                t = 52400,
                d = 2,
            },
            {
                t = 52600,
                d = 0,
            },
            {
                t = 52800,
                d = 2,
            },
            {
                t = 53400,
                d = 1,
            },
            {
                t = 53600,
                d = 0,
            },
            {
                t = 53800,
                d = 3,
            },
            {
                t = 53900,
                d = 2,
            },
            {
                t = 54000,
                d = 1,
            },
            {
                t = 54000,
                d = 0,
            },
            {
                t = 54200,
                d = 3,
            },
            {
                t = 54400,
                d = 0,
            },
            {
                t = 54600,
                d = 4,
            },
            {
                t = 54800,
                d = 5,
            },
            {
                t = 55000,
                d = 7,
            },
            {
                t = 55200,
                d = 4,
            },
            {
                t = 55200,
                d = 6,
            },
            {
                t = 55400,
                d = 1,
            },
            {
                t = 55400,
                d = 5,
            },
            {
                t = 55500,
                d = 7,
            },
            {
                t = 55600,
                d = 5,
            },
            {
                t = 55600,
                d = 4,
            },
            {
                t = 55800,
                d = 3,
            },
            {
                t = 56200,
                d = 6,
            },
            {
                t = 56400,
                d = 7,
            },
            {
                t = 56600,
                d = 1,
            },
            {
                t = 56600,
                d = 4,
            },
            {
                t = 56800,
                d = 3,
            },
            {
                t = 56800,
                d = 6,
            },
            {
                t = 56800,
                d = 7,
            },
            {
                t = 57000,
                d = 2,
            },
            {
                t = 57000,
                d = 5,
            },
            {
                t = 57100,
                d = 4,
            },
            {
                t = 57200,
                d = 0,
                k = "censor",
            },
            {
                t = 57200,
                d = 1,
                k = "censor",
            },
            {
                t = 57200,
                d = 6,
            },
            {
                t = 57200,
                d = 7,
            },
            {
                t = 57400,
                d = 3,
            },
            {
                t = 57600,
                d = 1,
            },
            {
                t = 57800,
                d = 5,
            },
            {
                t = 58000,
                d = 0,
            },
            {
                t = 58000,
                d = 4,
            },
            {
                t = 58200,
                d = 3,
            },
            {
                t = 58200,
                d = 6,
            },
            {
                t = 58400,
                d = 2,
            },
            {
                t = 58400,
                d = 7,
            },
            {
                t = 58400,
                d = 5,
            },
            {
                t = 58600,
                d = 1,
            },
            {
                t = 58600,
                d = 6,
            },
            {
                t = 58700,
                d = 4,
            },
            {
                t = 58800,
                d = 5,
            },
            {
                t = 58800,
                d = 6,
            },
            {
                t = 59000,
                d = 3,
            },
            {
                t = 59400,
                d = 0,
            },
            {
                t = 59400,
                d = 6,
            },
            {
                t = 59600,
                d = 1,
            },
            {
                t = 59600,
                d = 7,
            },
            {
                t = 59800,
                d = 3,
            },
            {
                t = 59800,
                d = 4,
            },
            {
                t = 60000,
                d = 1,
            },
            {
                t = 60000,
                d = 5,
            },
            {
                t = 60000,
                d = 6,
            },
            {
                t = 60200,
                d = 2,
            },
            {
                t = 60200,
                d = 7,
            },
            {
                t = 60300,
                d = 6,
            },
            {
                t = 60400,
                d = 0,
                l = 300,
            },
            {
                t = 60400,
                d = 4,
            },
            {
                t = 60400,
                d = 5,
            },
            {
                t = 60800,
                d = 3,
            },
            {
                t = 61200,
                d = 1,
            },
            {
                t = 61400,
                d = 0,
            },
            {
                t = 61600,
                d = 2,
            },
            {
                t = 61800,
                d = 3,
            },
            {
                t = 61800,
                d = 1,
            },
            {
                t = 62200,
                d = 0,
            },
            {
                t = 63000,
                d = 2,
            },
            {
                t = 63200,
                d = 3,
            },
            {
                t = 63400,
                d = 1,
            },
            {
                t = 63600,
                d = 3,
                k = "censor",
            },
            {
                t = 63600,
                d = 2,
                k = "censor",
            },
            {
                t = 63800,
                d = 0,
            },
            {
                t = 64000,
                d = 1,
            },
            {
                t = 64200,
                d = 0,
            },
            {
                t = 64400,
                d = 3,
            },
            {
                t = 64400,
                d = 2,
            },
            {
                t = 64600,
                d = 1,
            },
            {
                t = 65000,
                d = 2,
            },
            {
                t = 65400,
                d = 0,
            },
            {
                t = 65800,
                d = 1,
            },
            {
                t = 67200,
                d = 1,
            },
            {
                t = 67400,
                d = 7,
            },
            {
                t = 67600,
                d = 5,
            },
            {
                t = 67800,
                d = 0,
            },
            {
                t = 67800,
                d = 4,
            },
            {
                t = 68000,
                d = 1,
            },
            {
                t = 68000,
                d = 3,
            },
            {
                t = 68000,
                d = 7,
            },
            {
                t = 68200,
                d = 0,
            },
            {
                t = 68200,
                d = 5,
            },
            {
                t = 68400,
                d = 2,
            },
            {
                t = 68400,
                d = 1,
            },
            {
                t = 68400,
                d = 7,
            },
            {
                t = 68600,
                d = 3,
            },
            {
                t = 68600,
                d = 4,
            },
            {
                t = 68800,
                d = 6,
            },
            {
                t = 69000,
                d = 5,
            },
            {
                t = 69100,
                d = 4,
            },
            {
                t = 69200,
                d = 6,
            },
            {
                t = 69200,
                d = 7,
            },
            {
                t = 69400,
                d = 1,
            },
            {
                t = 69400,
                d = 5,
            },
            {
                t = 69600,
                d = 0,
            },
            {
                t = 69600,
                d = 2,
            },
            {
                t = 69600,
                d = 4,
                l = 350,
            },
            {
                t = 69800,
                d = 3,
            },
            {
                t = 69900,
                d = 2,
            },
            {
                t = 70000,
                d = 0,
            },
            {
                t = 70000,
                d = 1,
            },
            {
                t = 70000,
                d = 7,
            },
            {
                t = 70200,
                d = 3,
            },
            {
                t = 70400,
                d = 1,
            },
            {
                t = 70600,
                d = 6,
            },
            {
                t = 70800,
                d = 5,
            },
            {
                t = 71000,
                d = 2,
            },
            {
                t = 71000,
                d = 7,
            },
            {
                t = 71000,
                d = 6,
            },
            {
                t = 71200,
                d = 1,
            },
            {
                t = 71200,
                d = 5,
            },
            {
                t = 71400,
                d = 3,
            },
            {
                t = 71400,
                d = 4,
            },
            {
                t = 71600,
                d = 0,
            },
            {
                t = 71600,
                d = 1,
            },
            {
                t = 71600,
                d = 7,
            },
            {
                t = 71800,
                d = 3,
            },
            {
                t = 71800,
                d = 6,
            },
            {
                t = 72000,
                d = 4,
            },
            {
                t = 72200,
                d = 5,
            },
            {
                t = 72400,
                d = 6,
            },
            {
                t = 72600,
                d = 4,
            },
            {
                t = 72800,
                d = 5,
                l = 350,
            },
            {
                t = 73000,
                d = 1,
            },
            {
                t = 73200,
                d = 0,
            },
            {
                t = 73200,
                d = 7,
            },
            {
                t = 73400,
                d = 2,
            },
            {
                t = 73500,
                d = 3,
            },
            {
                t = 73600,
                d = 0,
            },
            {
                t = 73800,
                d = 1,
            },
            {
                t = 73900,
                d = 3,
            },
            {
                t = 74000,
                d = 1,
            },
            {
                t = 74200,
                d = 2,
            },
            {
                t = 74400,
                d = 3,
            },
            {
                t = 74400,
                d = 0,
            },
            {
                t = 74600,
                d = 1,
            },
            {
                t = 74800,
                d = 0,
            },
            {
                t = 75400,
                d = 3,
            },
            {
                t = 75600,
                d = 1,
            },
            {
                t = 75800,
                d = 2,
            },
            {
                t = 76000,
                d = 0,
            },
            {
                t = 76000,
                d = 1,
            },
            {
                t = 76200,
                d = 3,
            },
            {
                t = 76400,
                d = 2,
            },
            {
                t = 77000,
                d = 1,
            },
            {
                t = 77200,
                d = 0,
            },
            {
                t = 77400,
                d = 3,
            },
            {
                t = 77600,
                d = 1,
            },
            {
                t = 77600,
                d = 2,
            },
            {
                t = 77800,
                d = 3,
            },
            {
                t = 78000,
                d = 0,
            },
            {
                t = 78400,
                d = 3,
            },
            {
                t = 78600,
                d = 2,
            },
            {
                t = 78800,
                d = 0,
            },
            {
                t = 79000,
                d = 1,
            },
            {
                t = 79200,
                d = 3,
            },
            {
                t = 79200,
                d = 2,
            },
            {
                t = 79400,
                d = 0,
            },
            {
                t = 79600,
                d = 2,
            },
            {
                t = 79600,
                d = 1,
            },
        },
    },
    generatedBy = "Friday Night Funkin' - v0.5.0 (develop:96c151c:MODIFIED) PROTOTYPE",
}