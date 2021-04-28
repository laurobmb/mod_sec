import time
from locust import HttpUser, task, between

class QuickstartUser(HttpUser):
    wait_time = between(1, 2.5)

    @task
    def hello_world(self):
        self.client.get("/objects")
        self.client.get("/Sistema/")
        self.client.get("/checkout#/cart")
        self.client.get("/characters")
        
    @task(3)
    def view_items(self):
        pages = [ "/weedy/p",
                  "/egfh4ret/p",
                  "/buzzlightyear/p",
                  "agua-minalba-500ml/p",
                  "ball/p" ]
        for rota in pages:
            self.client.get(rota)
            time.sleep(1)

    @task(7)
    def vector_attacks(self):
        attack = [ '/?exec=/bin/bash' , 
                   '/?q="><script>alert(1)</script>"' , 
                   "/?id=3 or 'a'='a'" ]
        for command in attack:
            self.client.get(command)
            time.sleep(1)

