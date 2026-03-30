import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.apache.solr.client.solrj.request.UpdateRequest;
import org.apache.solr.common.SolrInputDocument;

public class SolrTest {
    public static void main(String[] args) {
        // HAProxy 대신 도커 서비스 이름으로 접속
        String url = "http://localhost/solr/test_kr";
        
        try (HttpSolrClient client = new HttpSolrClient.Builder(url).build()) {
            System.out.println(">>> Client created successfully");

            SolrInputDocument doc = new SolrInputDocument();
            doc.addField("id", "test_1");
            doc.addField("title", "JDK 1.8 compatibility test");

            UpdateRequest req = new UpdateRequest();
            req.add(doc);
            
            // 실제 서버로 전송
            req.process(client);
            client.commit();
            
            System.out.println(">>> Update and Commit successful!");
        } catch (Exception e) {
            System.err.println(">>> TEST FAILED!");
            e.printStackTrace();
        }
    }
}
