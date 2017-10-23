import org.junit.Test;
import org.junit.runner.RunWith;

import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.WebElement;

import com.github.webdriverextensions.junitrunner.WebDriverRunner;
import com.github.webdriverextensions.junitrunner.annotations.*;
import static com.github.webdriverextensions.Bot.*;
import static java.util.concurrent.TimeUnit.SECONDS;

@RunWith(WebDriverRunner.class)
@Firefox
@Chrome
@InternetExplorer
public class WebDriverExtensionsExampleTest {

    @FindBy(name = "q")
    private WebElement queryInput;
    @FindBy(name = "btnG")
    private WebElement searchButton;
    @FindBy(id = "search")
    private WebElement searchResult;

    @Test
    public void searchGoogleForHelloWorldTest() {
        open("http://www.google.com");
        assertCurrentUrlContains("google");

        type("Hello World", queryInput);
        click(searchButton);

        waitFor(3, SECONDS);
        assertTextContains("Hello World", searchResult);
    }
}
