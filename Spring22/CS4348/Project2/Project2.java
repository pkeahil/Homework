import java.util.concurrent.Semaphore;

class Customer extends Thread {
    public Semaphore ticketTakerSem;
    public Semaphore boxOfficeAgentSem;
    public Semaphore concessionStandSem;

    public Customer(Semaphore t, Semaphore b, Semaphore c) {
        ticketTakerSem= t;
        boxOfficeAgentSem = b;
        concessionStandSem = c;
    }
    
    @Override
    public void run() {
        try {
            System.out.println(Thread.currentThread().getName() + " is waiting for box office agent...");
            boxOfficeAgentSem.acquire();
            System.out.println("Box office semaphore acquired. Serving " + Thread.currentThread().getName());

            System.out.println(Thread.currentThread().getName() + " is waiting for ticket taker...");
            ticketTakerSem.acquire();
            System.out.println("Ticket taker semaphore acquired. Serving " + Thread.currentThread().getName());

            System.out.println(Thread.currentThread().getName() + " is waiting for concession stand...");
            concessionStandSem.acquire();
            System.out.println("Concession stand semaphore acquired. Serving " + Thread.currentThread().getName());
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}

class BoxOfficeAgent extends Thread {
    public Semaphore agentSemaphore;

    public BoxOfficeAgent(Semaphore a) {
        agentSemaphore = a;
    }

    @Override
    public void run() {

    }
}


public class Project2 {
    public static void main(String[] args) {
        System.out.println("Hello world");

        Semaphore ticketTaker = new Semaphore(1, true); // semaphore for ticket takers
        Semaphore boxOfficeAgent = new Semaphore(2, true); // semaphore for box office agents
        Semaphore concessionStand = new Semaphore(1, true);// semaphore for concession stand worker
        
        for(int i = 0; i < 10; i++) {
            new Customer(ticketTaker, boxOfficeAgent, concessionStand).start();
        }
    }
}