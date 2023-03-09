package dk.kb.cache;

import org.apache.logging.log4j.*;
import javax.cache.*;
import javax.cache.configuration.*;
import javax.cache.Caching;
import javax.cache.CacheManager;
import javax.cache.Cache;
import javax.cache.expiry.*;
import javax.cache.spi.*;
import static javax.cache.expiry.Duration.ONE_DAY;
import static javax.cache.expiry.Duration.ONE_HOUR;
import static javax.cache.expiry.Duration.ONE_MINUTE;
import static javax.cache.expiry.Duration.ZERO;

public class Page
{

    Logger log = LogManager.getLogger(Page.class);
    private static Page page    = null;

    Cache<String, String> cache = null;
    //Cache cache = null;

    private Page() {
	//resolve a cache manager
	CachingProvider cachingProvider = Caching.getCachingProvider();
	CacheManager cacheManager = cachingProvider.getCacheManager();

	MutableConfiguration<String, String> config = new MutableConfiguration<>();
        config.setStoreByValue(true)
	    .setExpiryPolicyFactory(AccessedExpiryPolicy.factoryOf(ONE_DAY))
	    .setStatisticsEnabled(true);

	//create the cache
	this.cache = cacheManager.createCache("simpleCache", config);
    }

    public static Page getInstance() {
	if(page == null) {
	    page = new Page();
	}
	return page;
    }

    public String getText(String key) {
	String val = this.cache.get(key);

	if(val != null ) {
	    log.info("text in cache");
	    return val;
	}
	log.info("text is null");
	return null;
    }

    public void setText(String key,String doc) {
	this.cache.put(key, doc);
    }

}
