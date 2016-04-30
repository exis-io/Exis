/**
 * @memberof $riffle
 * @function xsContainers
 * @param {RiffleDomain=} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Container Container} appliance. Defaults to the apps Container appliance.
 * @description Creates a new {@link Container} class.
 * @returns {Container} A new Container object that can be used for interacting with a {@link /docs/appliances/Container Container} Appliance.
 * @example
 *
 * //create a Container instance from the proper Container subdomain of your app
 * var container = $riffle.xsContainers();
 *
 * //list the containers in the appliance
 * container.list().then(success, error);  
 *
 */

/**
 * @typedef Container
 * @description The Container class provides an API for interacting with an {@link /docs/appliances/Container Container} Appliance
 * @see {@link /docs/appliances/Container here} for documentation.
 * @example
 * //create a Container instance from the domain
 * var cntr = $riffle.xsContainers();
 *
 * //get data about users(email, name, etc.)
 * cntr.get_users().then(handler, error);
 */

/**
 * @memberof Container
 * @function image
 * @description Retrieve details about the image the container was created from.
 * @param {string} name - The name of the container.
 * @example
 * container.image(name).then(success, error);
 */

/**
 * @memberof Container
 * @function inspect
 * @description Retrieve details about the container.
 * @param {string} name - The name of the container.
 * @example
 * container.inspect(name).then(success, error);
 */

/**
 * @memberof Container
 * @function logs
 * @description Fetch the logs for the container.
 * @param {string} name - The name of the container.
 * @example
 * container.logs(name).then(success, error);
 */

/**
 * @memberof Container
 * @function restart
 * @description Restart the container.
 * @param {string} name - The name of the container.
 * @example
 * container.restart(name).then(success, error);
 */

/**
 * @memberof Container
 * @function start
 * @description Start the container.
 * @param {string} name - The name of the container.
 * @example
 * container.start(name).then(success, error);
 */

/**
 * @memberof Container
 * @function stop
 * @description Stop the running container.
 * @param {string} name - The name of the container.
 * @example
 * container.stop(name).then(success, error);
 */

/**
 * @memberof Container
 * @function top
 * @description See details about the running container.
 * @param {string} name - The name of the container.
 * @example
 * container.top(name).then(success, error);
 */
